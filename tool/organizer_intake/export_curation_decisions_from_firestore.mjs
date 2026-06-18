#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {pathToFileURL} from "node:url";
import {
  createFunctionsRequire,
  fromRepo,
  relativeToRepo,
} from "../lib/repo_paths.mjs";
import {
  applyFirestoreEmulatorHost,
  resolveFirebaseProjectId,
} from "../lib/firebase_project.mjs";
import {
  assertValidSchemaPayload,
  validateOrganizerIntakeCurationDecisionDocument,
} from "../contracts/generated/schema_contract_validators.mjs";

const curationCollection = "organizerIntakeCurationDecisions";
const defaultOutputRoot = fromRepo("tool/organizer_intake/curation_decisions");

if (isMain()) {
  await main();
}

export async function main(argv = process.argv.slice(2)) {
  const args = parseArgs(argv);
  if (args.help) {
    printHelp();
    return;
  }

  if (!args.date) {
    fail("--date <YYYY-MM-DD> is required for deterministic exports.");
  }
  if (!/^\d{4}-\d{2}-\d{2}$/.test(args.date)) {
    fail("--date must use YYYY-MM-DD.");
  }

  const projectId = args.fixture ?
    null :
    resolveFirebaseProjectId({env: args.env, project: args.project});
  const sourceLabel = args.sourceLabel ??
    args.env ??
    projectId ??
    "fixture";
  const batch = buildCurationDecisionBatchFromFirestoreDocs(
    args.fixture ?
      loadFixtureDocs(args.fixture) :
      await readFirestoreCurationDocs({projectId, emulatorHost: args.emulatorHost}),
    {
      date: args.date,
      sourceLabel,
    }
  );
  const outputPath = path.resolve(
    args.output ??
      path.join(defaultOutputRoot, `${batch.curationBatchId}.json`)
  );
  const rendered = `${stableStringify(batch)}\n`;

  if (args.check) {
    if (!fs.existsSync(outputPath)) {
      fail(`Missing export output: ${relativeToRepo(outputPath)}`);
    }
    const current = fs.readFileSync(outputPath, "utf8");
    if (current !== rendered) {
      fail(
        `Export output is stale: ${relativeToRepo(outputPath)}\n` +
          "Run the exporter without --check after reviewing the source."
      );
    }
    console.log(`Organizer intake Firestore curation export is current: ${relativeToRepo(outputPath)}`);
    return;
  }

  if (args.json) {
    console.log(JSON.stringify({
      mode: args.write ? "write" : "dry_run",
      projectId,
      fixture: args.fixture ? relativeToRepo(path.resolve(args.fixture)) : null,
      output: relativeToRepo(outputPath),
      operations: batch.operations.length,
      batch,
    }, null, 2));
  } else {
    printSummary({args, projectId, outputPath, batch});
  }

  if (!args.write) return;
  if (batch.operations.length === 0 && !args.allowEmpty) {
    fail("Refusing to write an empty export without --allow-empty.");
  }
  if (fs.existsSync(outputPath) && !args.allowOverwrite) {
    const current = fs.readFileSync(outputPath, "utf8");
    if (current !== rendered) {
      fail(
        `Refusing to overwrite existing export ${relativeToRepo(outputPath)} ` +
          "without --allow-overwrite."
      );
    }
  }
  fs.mkdirSync(path.dirname(outputPath), {recursive: true});
  fs.writeFileSync(outputPath, rendered);
  console.log(`Wrote ${relativeToRepo(outputPath)}.`);
  console.log("Run: node tool/organizer_intake/organizer_intake.mjs");
}

export function buildCurationDecisionBatchFromFirestoreDocs(
  docs,
  {date, sourceLabel}
) {
  const curationBatchId = `firestore-${slugify(sourceLabel)}-${date}`;
  const operations = docs
    .map((doc) => validatedCurationDoc(doc))
    .filter((data) => data.operationStatus === "active")
    .sort((a, b) => a.operationId.localeCompare(b.operationId))
    .map((data) => curationOperationFor(data));

  return {
    schemaVersion: 1,
    curationBatchId,
    decidedAt: date,
    reviewer: `firestore:${slugify(sourceLabel)}`,
    operations,
  };
}

async function readFirestoreCurationDocs({projectId, emulatorHost}) {
  applyFirestoreEmulatorHost(emulatorHost);
  const requireFromFunctions = createFunctionsRequire();
  const admin = requireFromFunctions("firebase-admin");
  if (admin.apps.length === 0) {
    admin.initializeApp({projectId});
  }
  const snapshot = await admin.firestore().collection(curationCollection).get();
  return snapshot.docs.map((doc) => ({
    id: doc.id,
    path: doc.ref.path,
    data: doc.data(),
  }));
}

function loadFixtureDocs(fixturePath) {
  const absolutePath = path.resolve(fixturePath);
  const payload = JSON.parse(fs.readFileSync(absolutePath, "utf8"));
  if (Array.isArray(payload)) return normalizeFixtureDocs(payload);
  if (Array.isArray(payload.docs)) return normalizeFixtureDocs(payload.docs);
  if (payload && typeof payload === "object") {
    return Object.entries(payload).map(([id, data]) => ({
      id,
      path: `${curationCollection}/${id}`,
      data,
    }));
  }
  throw new Error(`Unsupported fixture shape: ${relativeToRepo(absolutePath)}`);
}

function normalizeFixtureDocs(docs) {
  return docs.map((doc) => {
    if (doc.data && typeof doc.data === "object") {
      return {
        id: doc.id ?? doc.data.operationId,
        path: doc.path ?? `${curationCollection}/${doc.id ?? doc.data.operationId}`,
        data: doc.data,
      };
    }
    if (doc.operationId) {
      return {
        id: doc.operationId,
        path: `${curationCollection}/${doc.operationId}`,
        data: doc,
      };
    }
    throw new Error("Every fixture document must include data or operationId.");
  });
}

function validatedCurationDoc(doc) {
  const label = doc.path ?? `${curationCollection}/${doc.id ?? "<unknown>"}`;
  const data = doc.data;
  if (!data || typeof data !== "object") {
    throw new Error(`${label}: missing Firestore curation data.`);
  }
  const schemaData = schemaSerializableFirestoreData(data);
  assertValidSchemaPayload(
    validateOrganizerIntakeCurationDecisionDocument,
    schemaData,
    label
  );
  if (doc.id && doc.id !== data.operationId) {
    throw new Error(
      `${label}: document id does not match operationId ${data.operationId}.`
    );
  }
  assertOperationComplete(data, label);
  return data;
}

function curationOperationFor(data) {
  if (data.operationType === "attach_surface") {
    return {
      type: "attach_surface",
      entityId: data.entityId,
      sourceCandidateId: data.sourceCandidateId,
      surface: data.surface,
      reason: data.reason,
    };
  }
  if (data.operationType === "merge_entity") {
    return {
      type: "merge_entity",
      sourceEntityId: data.sourceEntityId,
      targetEntityId: data.targetEntityId,
      reason: data.reason,
    };
  }
  if (data.operationType === "suppress_entity") {
    return {
      type: "suppress_entity",
      entityId: data.entityId,
      reason: data.reason,
    };
  }
  if (data.operationType === "surface_decision") {
    return {
      type: "surface_decision",
      entityId: data.entityId,
      surfaceId: data.surfaceId,
      decision: data.decision,
      reason: data.reason,
    };
  }
  return {
    type: "split_surface",
    entityId: data.entityId,
    surfaceId: data.surfaceId,
    newEntityId: data.newEntityId,
    reason: data.reason,
  };
}

function assertOperationComplete(data, label) {
  if (data.operationStatus !== "active") return;
  if (data.operationType === "attach_surface") {
    requireFields(data, label, ["entityId", "sourceCandidateId", "surface"]);
    if (data.surface?.crawl?.eventDiscoveryStatus !== "disabled") {
      throw new Error(`${label}: attach_surface must keep crawl disabled.`);
    }
    return;
  }
  if (data.operationType === "merge_entity") {
    requireFields(data, label, ["sourceEntityId", "targetEntityId"]);
    if (data.sourceEntityId === data.targetEntityId) {
      throw new Error(`${label}: merge_entity cannot merge an entity into itself.`);
    }
    return;
  }
  if (data.operationType === "suppress_entity") {
    requireFields(data, label, ["entityId"]);
    return;
  }
  if (data.operationType === "surface_decision") {
    requireFields(data, label, ["entityId", "surfaceId", "decision"]);
    return;
  }
  requireFields(data, label, ["entityId", "surfaceId", "newEntityId"]);
}

function requireFields(data, label, fields) {
  for (const field of fields) {
    if (data[field] === undefined || data[field] === null || data[field] === "") {
      throw new Error(`${label}: ${data.operationType} requires ${field}.`);
    }
  }
}

function schemaSerializableFirestoreData(value) {
  if (value === undefined) return undefined;
  if (value === null) return null;
  if (isFirestoreTimestamp(value)) {
    return {
      _seconds: value.seconds,
      _nanoseconds: value.nanoseconds,
    };
  }
  if (isFixtureTimestamp(value)) return value;
  if (Array.isArray(value)) {
    return value.map((item) => schemaSerializableFirestoreData(item));
  }
  if (typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value)
        .map(([key, item]) => [key, schemaSerializableFirestoreData(item)])
        .filter(([, item]) => item !== undefined)
    );
  }
  return value;
}

function isFirestoreTimestamp(value) {
  return value &&
    typeof value === "object" &&
    Number.isInteger(value.seconds) &&
    Number.isInteger(value.nanoseconds);
}

function isFixtureTimestamp(value) {
  return value &&
    typeof value === "object" &&
    Number.isInteger(value._seconds) &&
    Number.isInteger(value._nanoseconds);
}

function parseArgs(argv) {
  const parsed = {
    allowEmpty: false,
    allowOverwrite: false,
    check: false,
    date: null,
    emulatorHost: null,
    env: null,
    fixture: null,
    help: false,
    json: false,
    output: null,
    project: null,
    sourceLabel: null,
    write: false,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--allow-empty") parsed.allowEmpty = true;
    else if (arg === "--allow-overwrite") parsed.allowOverwrite = true;
    else if (arg === "--check") parsed.check = true;
    else if (arg === "--emulator") parsed.emulatorHost = "127.0.0.1:8080";
    else if (arg === "--json") parsed.json = true;
    else if (arg === "--write") parsed.write = true;
    else if (arg === "--date") parsed.date = requiredValue(argv, ++index, arg);
    else if (arg === "--emulator-host") parsed.emulatorHost = requiredValue(argv, ++index, arg);
    else if (arg === "--env") parsed.env = requiredValue(argv, ++index, arg);
    else if (arg === "--fixture") parsed.fixture = requiredValue(argv, ++index, arg);
    else if (arg === "--output") parsed.output = requiredValue(argv, ++index, arg);
    else if (arg === "--project") parsed.project = requiredValue(argv, ++index, arg);
    else if (arg === "--source-label") parsed.sourceLabel = requiredValue(argv, ++index, arg);
    else fail(`Unknown argument: ${arg}`);
  }
  return parsed;
}

function requiredValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) fail(`${flag} requires a value.`);
  return value;
}

function slugify(value) {
  return String(value ?? "export")
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "") || "export";
}

function stableStringify(value) {
  return JSON.stringify(sortValue(value), null, 2);
}

function sortValue(value) {
  if (Array.isArray(value)) return value.map(sortValue);
  if (!value || typeof value !== "object") return value;
  return Object.fromEntries(
    Object.entries(value)
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([key, nested]) => [key, sortValue(nested)])
  );
}

function printSummary({args, projectId, outputPath, batch}) {
  console.log("Organizer intake Firestore curation export");
  console.log(`Mode: ${args.write ? "write" : "dry run"}`);
  console.log(`Source: ${args.fixture ? relativeToRepo(path.resolve(args.fixture)) : projectId}`);
  console.log(`Output: ${relativeToRepo(outputPath)}`);
  console.log(`Curation batch: ${batch.curationBatchId}`);
  console.log(`Operations: ${batch.operations.length}`);
  for (const operation of batch.operations) {
    console.log(`- ${operation.type}: ${operation.reason}`);
  }
  if (!args.write) {
    console.log("\nDry run only. Re-run with --write to create/update the local curation file.");
  }
}

function printHelp() {
  console.log(`Usage: node tool/organizer_intake/export_curation_decisions_from_firestore.mjs [options]

Exports low-volume live admin curation operations from
organizerIntakeCurationDecisions/{operationId} into the repo-backed
tool/organizer_intake/curation_decisions/*.json format consumed by organizer
intake generation.

This tool performs remote reads only. It never writes Firestore and only writes
local JSON when --write is supplied.

Options:
  --date <YYYY-MM-DD>       Required deterministic export date.
  --env <dev|staging|prod>  Resolve Firebase project id from .firebaserc.
  --project <id>            Firebase project id.
  --emulator                Use Firestore emulator at 127.0.0.1:8080.
  --emulator-host <host>    Use a custom Firestore emulator host.
  --fixture <path>          Read local fixture docs instead of Firestore.
  --source-label <label>    Label used in curationBatchId and reviewer.
  --output <path>           Output JSON path. Defaults to curation_decisions/.
  --write                   Write the local export. Default is dry run.
  --check                   Verify output path is current.
  --allow-overwrite         Permit replacing an existing different file.
  --allow-empty             Permit writing an export with zero operations.
  --json                    Print machine-readable output.
  -h, --help                Show this help.

Examples:
  node tool/organizer_intake/export_curation_decisions_from_firestore.mjs \\
    --env dev --date 2026-06-17

  node tool/organizer_intake/export_curation_decisions_from_firestore.mjs \\
    --env prod --date 2026-06-17 --write
`);
}

function fail(message) {
  console.error(message);
  process.exit(1);
}

function isMain() {
  return process.argv[1] &&
    import.meta.url === pathToFileURL(process.argv[1]).href;
}
