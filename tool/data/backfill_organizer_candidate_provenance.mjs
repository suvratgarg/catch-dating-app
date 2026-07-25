#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {createRequire} from "node:module";
import {isDeepStrictEqual} from "node:util";
import {fileURLToPath} from "node:url";

const toolPath = fileURLToPath(import.meta.url);
const repoRoot = path.resolve(path.dirname(toolPath), "../..");
const requireFromFunctions = createRequire(
  path.join(repoRoot, "functions/package.json")
);

if (process.argv[1] && path.resolve(process.argv[1]) === toolPath) {
  await main();
}

export async function main(argv = process.argv.slice(2)) {
  const args = parseArgs(argv);
  if (args.help) return printHelp();
  const projectId = resolveProjectId(args);
  if (args.apply && isProductionTarget(args, projectId) && !args.allowProd) {
    throw new Error(
      "Refusing to backfill prod without --allow-prod. " +
      "Run a dry run first, then rerun with --apply --allow-prod."
    );
  }
  if (args.emulatorHost) {
    process.env.FIRESTORE_EMULATOR_HOST = args.emulatorHost;
  }
  const admin = requireFromFunctions("firebase-admin");
  admin.initializeApp({projectId});
  const db = admin.firestore();
  const plan = await buildOrganizerCandidateProvenanceRepairPlan(db);
  console.log(JSON.stringify(plan.summary, null, 2));
  if (!args.apply) {
    console.log("\nDry run only. Re-run with --apply to write repairs.");
    return;
  }
  await applyOrganizerCandidateProvenanceRepairPlan(db, plan);
  console.log("\nApplied organizer candidate provenance repairs.");
}

export async function buildOrganizerCandidateProvenanceRepairPlan(
  firestore
) {
  const snapshot = await firestore.collection("operationWorkItems").get();
  const repairs = [];
  let candidateItems = 0;
  let alreadyCurrent = 0;
  let missingEvidence = 0;
  for (const doc of snapshot.docs) {
    const item = doc.data();
    const candidate = organizerCandidate(item);
    if (!candidate) continue;
    candidateItems += 1;
    const expected = organizerCandidateFieldProvenance(item, candidate);
    if (expected.length === 0) {
      missingEvidence += 1;
      continue;
    }
    if (isDeepStrictEqual(item.fieldProvenance ?? [], expected)) {
      alreadyCurrent += 1;
      continue;
    }
    repairs.push({
      path: doc.ref.path,
      workItemId: doc.id,
      candidateId: candidate.candidateId,
      currentFieldCount: Array.isArray(item.fieldProvenance) ?
        item.fieldProvenance.length :
        0,
      expectedFieldCount: expected.length,
      patch: {fieldProvenance: expected},
    });
  }
  return {
    repairs,
    summary: {
      workItemsScanned: snapshot.size,
      candidateItems,
      repairsNeeded: repairs.length,
      alreadyCurrent,
      missingEvidence,
      repairs: repairs.map(({patch: _patch, ...repair}) => repair),
    },
  };
}

export function organizerCandidateFieldProvenance(item, candidate) {
  const evidence = item.evidenceRefs?.[0];
  if (!evidence?.artifactId || !evidence?.contentHash) return [];
  const confidence = typeof item.normalizedPayload?.confidence?.overall ===
    "number" ?
    item.normalizedPayload.confidence.overall :
    null;
  const retained = (Array.isArray(item.fieldProvenance) ?
    item.fieldProvenance :
    []).filter((entry) => !String(entry?.field ?? "")
    .startsWith("intake.candidate."));
  const fields = [
    ["intake.candidate.title", candidate.title],
    ["intake.candidate.canonicalUrl", candidate.canonicalUrl],
    ["intake.candidate.snippet", candidate.snippet],
    [
      "intake.candidate.queryIntent.marketSlug",
      candidate.queryIntent?.marketSlug,
    ],
    [
      "intake.candidate.reviewContext.formats",
      candidate.reviewContext?.formats,
    ],
    [
      "intake.candidate.reviewContext.reviewNotes",
      candidate.reviewContext?.reviewNotes,
    ],
    [
      "intake.candidate.reviewContext.verifiedAt",
      candidate.reviewContext?.verifiedAt,
    ],
  ].filter(([, value]) =>
    value !== null &&
    value !== undefined &&
    (!Array.isArray(value) || value.length > 0));
  const base = evidence.locator ?? "operationWorkItems";
  return [
    ...retained,
    ...fields.map(([field]) => ({
      field,
      artifactId: evidence.artifactId,
      contentHash: evidence.contentHash,
      locator: `${base}#normalizedPayload.${field}`,
      extractedBy: "deterministic",
      extractorVersion: "supply-intake-v0.1.1",
      confidence,
    })),
  ];
}

export async function applyOrganizerCandidateProvenanceRepairPlan(
  firestore,
  plan
) {
  for (let index = 0; index < plan.repairs.length; index += 450) {
    const batch = firestore.batch();
    for (const repair of plan.repairs.slice(index, index + 450)) {
      batch.update(firestore.doc(repair.path), repair.patch);
    }
    await batch.commit();
  }
}

function organizerCandidate(item) {
  if (
    item?.workflowId !== "supply-intake" ||
    item?.entityKind !== "organizer"
  ) return null;
  const intake = item.normalizedPayload?.intake;
  if (intake?.recordType !== "organizer_search_candidate") return null;
  return intake.candidate && typeof intake.candidate === "object" ?
    intake.candidate :
    null;
}

function parseArgs(argv) {
  const parsed = {
    env: null,
    project: null,
    emulatorHost: null,
    apply: false,
    allowProd: false,
    help: false,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--apply") parsed.apply = true;
    else if (arg === "--allow-prod") parsed.allowProd = true;
    else if (arg === "--emulator") {
      parsed.emulatorHost = "127.0.0.1:8080";
    } else if (arg === "--emulator-host") {
      parsed.emulatorHost = requireValue(argv, ++index, arg);
    } else if (arg === "--env") {
      parsed.env = requireValue(argv, ++index, arg);
    } else if (arg === "--project") {
      parsed.project = requireValue(argv, ++index, arg);
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }
  return parsed;
}

function requireValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) {
    throw new Error(`${flag} requires a value.`);
  }
  return value;
}

function resolveProjectId(args) {
  if (args.project) return args.project;
  if (args.env) {
    const project = readFirebaseRc().projects?.[args.env];
    if (!project) throw new Error(`No Firebase project for env: ${args.env}`);
    return project;
  }
  return process.env.GCLOUD_PROJECT ||
    process.env.GOOGLE_CLOUD_PROJECT ||
    "catchdates-dev";
}

function isProductionTarget(args, projectId) {
  return args.env === "prod" || projectId === readFirebaseRc().projects?.prod;
}

function readFirebaseRc() {
  return JSON.parse(fs.readFileSync(path.join(repoRoot, ".firebaserc"), "utf8"));
}

function printHelp() {
  console.log(`Usage: node tool/data/backfill_organizer_candidate_provenance.mjs [options]

Backfills field provenance on persisted Supply Intake organizer candidates.
Firestore is the source and destination; the tool does not read repository
operational JSON. It is dry-run by default.

Options:
  --apply                 Write repairs. Default is dry-run.
  --allow-prod            Required with --apply against prod.
  --env <dev|staging|prod> Resolve project id from .firebaserc.
  --project <id>          Firebase project id.
  --emulator              Use Firestore emulator at 127.0.0.1:8080.
  --emulator-host <host>  Use a custom Firestore emulator host.
  -h, --help              Show this help.
`);
}
