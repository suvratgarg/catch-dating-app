#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {createRequire} from "node:module";
import {fileURLToPath} from "node:url";
import {parseCommonArgs} from "../lib/cli_args.mjs";
import {
  buildLegacyHostContactProjectionAudit,
  classifyLegacyContactProjection,
} from "./audit_legacy_host_contact_projection.mjs";

const toolPath = fileURLToPath(import.meta.url);
const repoRoot = path.resolve(path.dirname(toolPath), "../..");
const requireFromFunctions = createRequire(
  path.join(repoRoot, "functions/package.json")
);
const options = {
  valueFlags: [
    "--organizer-id",
    "--expected-high-confidence",
    "--expected-human-reconciliation",
  ],
  allowPositionals: false,
  customFieldCase: "camel",
};

if (process.argv[1] && path.resolve(process.argv[1]) === toolPath) {
  await main();
}

export async function main(argv = process.argv.slice(2)) {
  const args = parseCommonArgs(argv, options);
  if (args.help) return printHelp();
  const projectId = resolveProjectId(args);
  const production = isProductionTarget(args, projectId);
  assertMutationGates(args, production);
  if (args.emulatorHost) {
    process.env.FIRESTORE_EMULATOR_HOST = args.emulatorHost;
  }
  const admin = requireFromFunctions("firebase-admin");
  if (admin.apps.length === 0) admin.initializeApp({projectId});
  const db = admin.firestore();
  const plan = await buildLegacyHostContactProjectionAudit(
    db,
    args.organizerId
  );
  assertExpectedPlan(plan, args);
  printPlan(plan, args, projectId);
  if (!args.apply) return;
  const result = await applyLegacyHostContactProjectionRepair({
    db,
    admin,
    plan,
    organizerId: args.organizerId,
  });
  console.log(JSON.stringify(result, null, 2));
}

export function assertExpectedPlan(plan, args) {
  const expectedHigh = integerFlag(
    args.expectedHighConfidence,
    "--expected-high-confidence"
  );
  const expectedHuman = integerFlag(
    args.expectedHumanReconciliation,
    "--expected-human-reconciliation"
  );
  if (plan.highConfidenceCount !== expectedHigh ||
      plan.humanReconciliationCount !== expectedHuman ||
      plan.organizers.length !== 1 ||
      plan.organizers[0]?.organizerId !== args.organizerId) {
    throw new Error(
      "Repair plan changed: expected " +
      `${expectedHigh} high-confidence and ${expectedHuman} reconciliation ` +
      `rows for ${args.organizerId}, received ` +
      `${plan.highConfidenceCount}, ${plan.humanReconciliationCount}. ` +
      "Stop and review a fresh audit."
    );
  }
  if (expectedHuman !== 0) {
    throw new Error("Repair never mutates human-reconciliation rows.");
  }
  if (plan.entries.some((entry) =>
    entry.classification !== "highConfidencePrivateProjection"
  )) {
    throw new Error("Repair plan contains a non-high-confidence row.");
  }
}

export async function applyLegacyHostContactProjectionRepair(params) {
  const evidenceIds = new Set();
  const phoneIdentityHashes = new Set();
  for (const entry of params.plan.entries) {
    const links = await params.db.collection("organizerContactIdentityLinks")
      .where("attendeeId", "==", entry.attendeeId).get();
    for (const linkSnap of links.docs) {
      const link = linkSnap.data();
      if (entry.projectedFields.includes("phoneE164") &&
          link.kind === "phone") {
        evidenceIds.add(linkSnap.id);
        if (typeof link.identityHash === "string") {
          phoneIdentityHashes.add(link.identityHash);
        }
      }
      if (entry.projectedFields.includes("email") && link.kind === "email") {
        evidenceIds.add(linkSnap.id);
      }
    }
  }

  const repaired = [];
  for (const entry of params.plan.entries) {
    const attendeeRef = params.db.collection("eventAttendees")
      .doc(entry.attendeeId);
    const repair = await params.db.runTransaction(async (tx) => {
      const attendeeSnap = await tx.get(attendeeRef);
      if (!attendeeSnap.exists) {
        throw new Error(`Attendee ${entry.attendeeId} no longer exists.`);
      }
      const attendee = attendeeSnap.data();
      const userSnap = await tx.get(
        params.db.collection("users").doc(attendee.linkedUid)
      );
      const current = classifyLegacyContactProjection(
        attendee,
        userSnap.exists ? userSnap.data() : undefined
      );
      if (current.classification !== "highConfidencePrivateProjection" ||
          JSON.stringify([...current.projectedFields].sort()) !==
            JSON.stringify([...entry.projectedFields].sort()) ||
          attendee.organizerId !== params.organizerId) {
        throw new Error(
          `Attendee ${entry.attendeeId} changed after the dry run. ` +
          "No mutation was made for this row."
        );
      }
      const updatedAt = params.admin.firestore.Timestamp.now();
      const patch = {updatedAt};
      for (const field of current.projectedFields) patch[field] = null;
      tx.update(attendeeRef, patch);
      return {attendeeId: entry.attendeeId, updatedAt};
    });
    repaired.push(repair);
  }

  const projection = await waitForProjection({
    db: params.db,
    repaired,
    evidenceIds,
    timeoutMillis: 55_000,
  });
  const removedOrphanClaimCount = await removeOrphanPhoneClaims({
    db: params.db,
    organizerId: params.organizerId,
    phoneIdentityHashes,
  });
  const remaining = await buildLegacyHostContactProjectionAudit(
    params.db,
    params.organizerId
  );
  if (remaining.candidateCount !== 0) {
    throw new Error(
      "Repair writes completed, but a fresh audit still found candidates. " +
      "Stop and reconcile before retrying."
    );
  }
  return {
    organizerId: params.organizerId,
    repairedAttendeeCount: repaired.length,
    projectedEdgeCount: projection.projectedEdgeCount,
    removedIdentityEvidenceCount: evidenceIds.size,
    removedOrphanClaimCount,
    remainingCandidateCount: 0,
    rawContactValuesPrinted: false,
  };
}

async function waitForProjection(params) {
  const deadline = Date.now() + params.timeoutMillis;
  while (Date.now() < deadline) {
    const edgeSnaps = await params.db.getAll(...params.repaired.map((row) =>
      params.db.collection("organizerContactEventEdges").doc(row.attendeeId)
    ));
    const evidenceSnaps = params.evidenceIds.size === 0 ? [] :
      await params.db.getAll(...[...params.evidenceIds].map((id) =>
        params.db.collection("organizerContactIdentityLinks").doc(id)
      ));
    const edgesCurrent = edgeSnaps.every((snap, index) =>
      snap.exists && snap.data().sourceUpdatedAt?.toMillis?.() ===
        params.repaired[index].updatedAt.toMillis()
    );
    const evidenceRemoved = evidenceSnaps.every((snap) => !snap.exists);
    if (edgesCurrent && evidenceRemoved) {
      return {projectedEdgeCount: edgeSnaps.length};
    }
    await new Promise((resolve) => setTimeout(resolve, 1500));
  }
  throw new Error(
    "Timed out waiting for the deployed audience projection to rebuild. " +
    "Do not rerun blindly; inspect the Functions trigger and fresh audit."
  );
}

async function removeOrphanPhoneClaims(params) {
  let removed = 0;
  for (const identityHash of params.phoneIdentityHashes) {
    const [links, claims] = await Promise.all([
      params.db.collection("organizerContactIdentityLinks")
        .where("identityHash", "==", identityHash).limit(1).get(),
      params.db.collection("organizerContactIdentityClaims")
        .where("identityHash", "==", identityHash).get(),
    ]);
    if (!links.empty) continue;
    const scopedClaims = claims.docs.filter((doc) =>
      doc.data().organizerId === params.organizerId
    );
    if (scopedClaims.length === 0) continue;
    const batch = params.db.batch();
    for (const claim of scopedClaims) batch.delete(claim.ref);
    await batch.commit();
    removed += scopedClaims.length;
  }
  return removed;
}

function assertMutationGates(args, production) {
  if (!args.organizerId) {
    throw new Error("--organizer-id is required; broad repairs are forbidden.");
  }
  integerFlag(args.expectedHighConfidence, "--expected-high-confidence");
  integerFlag(
    args.expectedHumanReconciliation,
    "--expected-human-reconciliation"
  );
  if (args.apply && production && (!args.allowProd || !args.confirmProd)) {
    throw new Error(
      "Production repair requires --apply --allow-prod --confirm-prod after " +
      "a fresh dry run with exact expected counts."
    );
  }
}

function integerFlag(value, name) {
  if (typeof value !== "string" || !/^[0-9]+$/u.test(value)) {
    throw new Error(`${name} is required and must be a non-negative integer.`);
  }
  return Number.parseInt(value, 10);
}

function resolveProjectId(args) {
  if (args.project) return args.project;
  if (args.env) {
    const project = readFirebaseRc().projects?.[args.env];
    if (!project) throw new Error(`Unknown Firebase alias: ${args.env}`);
    return project;
  }
  return process.env.GCLOUD_PROJECT ||
    process.env.GOOGLE_CLOUD_PROJECT || "catchdates-dev";
}

function isProductionTarget(args, projectId) {
  return args.env === "prod" || projectId === readFirebaseRc().projects?.prod;
}

function readFirebaseRc() {
  return JSON.parse(fs.readFileSync(path.join(repoRoot, ".firebaserc"), "utf8"));
}

function printPlan(plan, args, projectId) {
  console.log(JSON.stringify({
    projectId,
    organizerId: args.organizerId,
    apply: args.apply,
    highConfidenceCount: plan.highConfidenceCount,
    humanReconciliationCount: plan.humanReconciliationCount,
    projectedEdgeCount: plan.projectedEdgeCount,
    affectedContactCount: plan.affectedContactCount,
    rawContactValuesPrinted: false,
  }, null, 2));
}

function printHelp() {
  console.log(`Usage: node tool/data/repair_legacy_host_contact_projection.mjs [options]

Redacts only exact private-profile phone/email copies from one organizer's
high-confidence Catch-booking attendee rows. It never deletes customer or event
records and never prints raw contact values. The deployed attendee projection
must be current before applying because it rebuilds downstream CRM records.

Required:
  --organizer-id <id>
  --expected-high-confidence <count>
  --expected-human-reconciliation 0

Mutation gates:
  --apply
  --allow-prod --confirm-prod     Both required for production mutation.

Environment:
  --env <dev|staging|prod>
  --project <id>
  --emulator
  --emulator-host <host>
  -h, --help
`);
}
