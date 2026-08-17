#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {createRequire} from "node:module";
import {fileURLToPath} from "node:url";
import {parseCommonArgs} from "../lib/cli_args.mjs";

const toolPath = fileURLToPath(import.meta.url);
const repoRoot = path.resolve(path.dirname(toolPath), "../..");
const requireFromFunctions = createRequire(
  path.join(repoRoot, "functions/package.json")
);
const options = {
  booleanFlags: ["--include-ids"],
  valueFlags: ["--organizer-id"],
  allowPositionals: false,
  customFieldCase: "camel",
};

if (process.argv[1] && path.resolve(process.argv[1]) === toolPath) {
  await main();
}

export async function main(argv = process.argv.slice(2)) {
  const args = parseCommonArgs(argv, options);
  if (args.help) return printHelp();
  if (args.apply) {
    throw new Error(
      "This audit is permanently read-only. Review its counts before " +
      "designing a separate, approval-gated repair."
    );
  }
  if (args.emulatorHost) {
    process.env.FIRESTORE_EMULATOR_HOST = args.emulatorHost;
  }
  const projectId = resolveProjectId(args);
  const admin = requireFromFunctions("firebase-admin");
  if (admin.apps.length === 0) admin.initializeApp({projectId});
  const plan = await buildLegacyHostContactProjectionAudit(
    admin.firestore(),
    args.organizerId ?? null
  );
  printPlan(plan, args);
}

export async function buildLegacyHostContactProjectionAudit(
  db,
  organizerId = null
) {
  let query = db.collection("eventAttendees")
    .where("source", "==", "catchBooking");
  if (organizerId) query = query.where("organizerId", "==", organizerId);
  const attendeeSnapshot = await query.get();
  const attendeeRows = attendeeSnapshot.docs.map((doc) => ({
    id: doc.id,
    data: doc.data(),
  }));
  const linkedUids = [...new Set(attendeeRows
    .map((row) => row.data.linkedUid)
    .filter((uid) => typeof uid === "string" && uid.length > 0))];
  const usersByUid = await fetchDocumentsById(db, "users", linkedUids);
  const entries = attendeeRows.map((row) => ({
    attendeeId: row.id,
    organizerId: stringOrNull(row.data.organizerId),
    eventId: stringOrNull(row.data.eventId),
    ...classifyLegacyContactProjection(row.data, usersByUid.get(
      row.data.linkedUid
    )),
  })).filter((entry) => entry.classification !== "notCandidate");
  const downstreamEdges = await fetchDocumentsById(
    db,
    "organizerContactEventEdges",
    entries.map((entry) => entry.attendeeId)
  );
  for (const entry of entries) {
    const edge = downstreamEdges.get(entry.attendeeId);
    entry.contactId = stringOrNull(edge?.contactId);
    entry.hasProjectedEventEdge = edge !== undefined;
  }
  const organizerCounts = new Map();
  for (const entry of entries) {
    const key = entry.organizerId ?? "missing-organizer";
    const current = organizerCounts.get(key) ?? {
      organizerId: key,
      highConfidenceCount: 0,
      humanReconciliationCount: 0,
      projectedEdgeCount: 0,
      affectedContactIds: new Set(),
    };
    if (entry.classification === "highConfidencePrivateProjection") {
      current.highConfidenceCount += 1;
    } else {
      current.humanReconciliationCount += 1;
    }
    if (entry.hasProjectedEventEdge) current.projectedEdgeCount += 1;
    if (entry.contactId) current.affectedContactIds.add(entry.contactId);
    organizerCounts.set(key, current);
  }
  const organizers = [...organizerCounts.values()]
    .map((item) => ({
      organizerId: item.organizerId,
      highConfidenceCount: item.highConfidenceCount,
      humanReconciliationCount: item.humanReconciliationCount,
      projectedEdgeCount: item.projectedEdgeCount,
      affectedContactCount: item.affectedContactIds.size,
    }))
    .sort((left, right) => left.organizerId.localeCompare(right.organizerId));
  return {
    catchBookingRowsScanned: attendeeSnapshot.size,
    candidateCount: entries.length,
    highConfidenceCount: entries.filter((entry) =>
      entry.classification === "highConfidencePrivateProjection"
    ).length,
    humanReconciliationCount: entries.filter((entry) =>
      entry.classification === "humanReconciliationRequired"
    ).length,
    projectedEdgeCount: entries.filter((entry) =>
      entry.hasProjectedEventEdge
    ).length,
    affectedContactCount: new Set(entries
      .map((entry) => entry.contactId)
      .filter(Boolean)).size,
    organizers,
    entries,
  };
}

export function classifyLegacyContactProjection(attendee, privateProfile) {
  const phone = stringOrNull(attendee.phoneE164);
  const email = normalizeEmail(attendee.email);
  if (attendee.source !== "catchBooking" ||
      typeof attendee.linkedUid !== "string" ||
      attendee.linkedUid.length === 0 ||
      (!phone && !email)) {
    return emptyClassification("notCandidate", []);
  }
  const reasons = [];
  const projectedFields = [];
  const mismatchedFields = [];
  const hasOperationalProvenance = [
    attendee.importId,
    attendee.sourceRowId,
    attendee.externalReference,
    attendee.providerGuestId,
    attendee.providerConnectionId,
  ].some((value) => typeof value === "string" && value.length > 0);
  if (hasOperationalProvenance) reasons.push("operationalContactProvenance");
  if (!privateProfile) {
    reasons.push("privateProfileUnavailable");
  } else {
    if (phone) {
      if (phone === normalizePhone(privateProfile.phoneNumber)) {
        projectedFields.push("phoneE164");
      } else {
        mismatchedFields.push("phoneE164");
      }
    }
    if (email) {
      if (email === normalizeEmail(privateProfile.email)) {
        projectedFields.push("email");
      } else {
        mismatchedFields.push("email");
      }
    }
  }
  if (mismatchedFields.length > 0) reasons.push("privateProfileMismatch");
  if (projectedFields.length === 0) reasons.push("noExactPrivateProfileMatch");
  const highConfidence = projectedFields.length > 0 &&
    mismatchedFields.length === 0 && !hasOperationalProvenance;
  return {
    classification: highConfidence ?
      "highConfidencePrivateProjection" :
      "humanReconciliationRequired",
    projectedFields,
    mismatchedFields,
    reasons,
  };
}

function emptyClassification(classification, reasons) {
  return {classification, projectedFields: [], mismatchedFields: [], reasons};
}

async function fetchDocumentsById(db, collectionName, ids) {
  const result = new Map();
  for (let index = 0; index < ids.length; index += 250) {
    const chunk = ids.slice(index, index + 250);
    if (chunk.length === 0) continue;
    const snapshots = await db.getAll(...chunk.map((id) =>
      db.collection(collectionName).doc(id)
    ));
    for (const snapshot of snapshots) {
      if (snapshot.exists) result.set(snapshot.id, snapshot.data());
    }
  }
  return result;
}

function normalizePhone(value) {
  const normalized = stringOrNull(value)?.replace(/[\s().-]/gu, "") ?? null;
  return normalized && /^\+[1-9][0-9]{7,14}$/u.test(normalized) ?
    normalized : null;
}

function normalizeEmail(value) {
  return stringOrNull(value)?.toLocaleLowerCase("en") ?? null;
}

function stringOrNull(value) {
  return typeof value === "string" && value.trim().length > 0 ?
    value.trim() : null;
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

function readFirebaseRc() {
  return JSON.parse(fs.readFileSync(path.join(repoRoot, ".firebaserc"), "utf8"));
}

function printPlan(plan, args) {
  const safePlan = args.includeIds ? plan : {...plan, entries: undefined};
  if (args.json) {
    console.log(JSON.stringify(safePlan, null, 2));
    return;
  }
  console.log("Legacy Host contact projection audit (read-only)");
  console.log(`Catch-booking rows scanned: ${plan.catchBookingRowsScanned}`);
  console.log(`High-confidence private projections: ${plan.highConfidenceCount}`);
  console.log(`Human reconciliation required: ${plan.humanReconciliationCount}`);
  console.log(`Projected event edges affected: ${plan.projectedEdgeCount}`);
  console.log(`Organizer contacts affected: ${plan.affectedContactCount}`);
  for (const organizer of plan.organizers) {
    console.log(
      `- ${organizer.organizerId}: ` +
      `${organizer.highConfidenceCount} high-confidence, ` +
      `${organizer.humanReconciliationCount} review`
    );
  }
  console.log("No writes were attempted. Raw phone and email values are omitted.");
}

function printHelp() {
  console.log(`Usage: node tool/data/audit_legacy_host_contact_projection.mjs [options]

Audits legacy Catch-booking attendee rows for phone/email values that exactly
match the linked private profile and lack organizer/provider acquisition
provenance. It never writes and never prints raw contact values.

Options:
  --organizer-id <id>       Restrict the audit to one organizer.
  --include-ids             Include opaque row/contact ids in JSON output.
  --json                    Print JSON instead of a text summary.
  --env <dev|staging|prod>  Resolve project id from .firebaserc.
  --project <id>            Firebase project id.
  --emulator                Use Firestore emulator at 127.0.0.1:8080.
  --emulator-host <host>    Use a custom Firestore emulator host.
  -h, --help                Show this help.
`);
}
