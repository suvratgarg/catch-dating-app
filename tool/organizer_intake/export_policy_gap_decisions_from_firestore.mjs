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
  validateOrganizerPolicyGapReviewDecisionDocument,
} from "../contracts/generated/schema_contract_validators.mjs";

const decisionCollection = "organizerPolicyGapReviewDecisions";
const defaultOutputRoot = fromRepo("tool/organizer_intake/policy_gap_decisions");

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
  const batch = buildPolicyGapDecisionBatchFromFirestoreDocs(
    args.fixture ?
      loadFixtureDocs(args.fixture) :
      await readFirestoreDecisionDocs({projectId, emulatorHost: args.emulatorHost}),
    {
      date: args.date,
      sourceLabel,
    }
  );
  const outputPath = path.resolve(
    args.output ??
      path.join(defaultOutputRoot, `${batch.policyGapDecisionBatchId}.json`)
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
    console.log(`Organizer policy gap export is current: ${relativeToRepo(outputPath)}`);
    return;
  }

  if (args.json) {
    console.log(JSON.stringify({
      mode: args.write ? "write" : "dry_run",
      projectId,
      fixture: args.fixture ? relativeToRepo(path.resolve(args.fixture)) : null,
      output: relativeToRepo(outputPath),
      decisions: batch.decisions.length,
      batch,
    }, null, 2));
  } else {
    printSummary({args, projectId, outputPath, batch});
  }

  if (!args.write) return;
  if (batch.decisions.length === 0 && !args.allowEmpty) {
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

export function buildPolicyGapDecisionBatchFromFirestoreDocs(
  docs,
  {date, sourceLabel}
) {
  const policyGapDecisionBatchId = `firestore-${slugify(sourceLabel)}-${date}`;
  const decisions = docs.map((doc) => {
    const label = doc.path ?? `${decisionCollection}/${doc.id ?? "<unknown>"}`;
    const data = doc.data;
    if (!data || typeof data !== "object") {
      throw new Error(`${label}: missing Firestore policy-gap decision data.`);
    }
    const schemaData = schemaSerializableFirestoreData(data);
    assertValidSchemaPayload(
      validateOrganizerPolicyGapReviewDecisionDocument,
      schemaData,
      label
    );
    if (doc.id && doc.id !== data.decisionId) {
      throw new Error(
        `${label}: document id does not match decisionId ${data.decisionId}.`
      );
    }
    assertDecisionStatusMatches(data, label);
    return {
      gapId: data.gapId,
      decision: data.decision,
      requiredInputsReviewed: data.requiredInputsReviewed,
      note: data.note,
    };
  }).sort((a, b) => a.gapId.localeCompare(b.gapId));

  return {
    schemaVersion: 1,
    policyGapDecisionBatchId,
    decidedAt: date,
    reviewer: `firestore:${slugify(sourceLabel)}`,
    decisions,
  };
}

async function readFirestoreDecisionDocs({projectId, emulatorHost}) {
  applyFirestoreEmulatorHost(emulatorHost);
  const requireFromFunctions = createFunctionsRequire();
  const admin = requireFromFunctions("firebase-admin");
  if (admin.apps.length === 0) {
    admin.initializeApp({projectId});
  }
  const snapshot = await admin.firestore().collection(decisionCollection).get();
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
      path: `${decisionCollection}/${id}`,
      data,
    }));
  }
  throw new Error(`Unsupported fixture shape: ${relativeToRepo(absolutePath)}`);
}

function normalizeFixtureDocs(docs) {
  return docs.map((doc) => {
    if (doc.data && typeof doc.data === "object") {
      return {
        id: doc.id ?? doc.data.decisionId,
        path: doc.path ?? `${decisionCollection}/${doc.id ?? doc.data.decisionId}`,
        data: doc.data,
      };
    }
    if (doc.decisionId) {
      return {
        id: doc.decisionId,
        path: `${decisionCollection}/${doc.decisionId}`,
        data: doc,
      };
    }
    throw new Error("Every fixture document must include data or decisionId.");
  });
}

function assertDecisionStatusMatches(data, label) {
  const expectedStatus = {
    accept: "accepted",
    hold: "held",
    reject: "rejected",
  }[data.decision];
  if (data.decisionStatus !== expectedStatus) {
    throw new Error(
      `${label}: decisionStatus ${data.decisionStatus} does not match ` +
        `${data.decision}.`
    );
  }
  const expectedOperationalState = data.decision === "reject" ?
    "not_approved" :
    "blocked_until_policy_encoded";
  if (data.operationalState !== expectedOperationalState) {
    throw new Error(
      `${label}: operationalState ${data.operationalState} does not match ` +
        `${data.decision}.`
    );
  }
  if (data.decision === "accept") {
    if (data.requiredInputsReviewed.length === 0) {
      throw new Error(
        `${label}: accept decision has no reviewed required inputs.`
      );
    }
    if (!checklistComplete(data.checklist)) {
      throw new Error(`${label}: accept decision has an incomplete checklist.`);
    }
  }
}

function checklistComplete(checklist) {
  return Boolean(
    checklist?.requiredInputsReviewed &&
      checklist?.costAndSafetyReviewed &&
      checklist?.implementationOwnerReviewed &&
      checklist?.behaviorStillDisabledAcknowledged
  );
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
  return Boolean(
    value &&
      typeof value === "object" &&
      typeof value.seconds === "number" &&
      typeof value.nanoseconds === "number"
  );
}

function isFixtureTimestamp(value) {
  return Boolean(
    value &&
      typeof value === "object" &&
      Number.isInteger(value._seconds) &&
      Number.isInteger(value._nanoseconds)
  );
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
    if (arg === "--allow-empty") parsed.allowEmpty = true;
    else if (arg === "--allow-overwrite") parsed.allowOverwrite = true;
    else if (arg === "--check") parsed.check = true;
    else if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--json") parsed.json = true;
    else if (arg === "--write") parsed.write = true;
    else if (arg === "--date") parsed.date = requiredValue(argv, ++index, arg);
    else if (arg === "--emulator") parsed.emulatorHost = "127.0.0.1:8080";
    else if (arg === "--emulator-host") {
      parsed.emulatorHost = requiredValue(argv, ++index, arg);
    } else if (arg === "--env") {
      parsed.env = requiredValue(argv, ++index, arg);
    } else if (arg === "--fixture") {
      parsed.fixture = requiredValue(argv, ++index, arg);
    } else if (arg === "--output") {
      parsed.output = requiredValue(argv, ++index, arg);
    } else if (arg === "--project") {
      parsed.project = requiredValue(argv, ++index, arg);
    } else if (arg === "--source-label") {
      parsed.sourceLabel = requiredValue(argv, ++index, arg);
    } else {
      fail(`Unknown argument: ${arg}`);
    }
  }

  return parsed;
}

function requiredValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) fail(`${flag} requires a value.`);
  return value;
}

function printSummary({args, projectId, outputPath, batch}) {
  console.log("Organizer intake Firestore policy-gap export");
  console.log(`Mode: ${args.write ? "write" : "dry run"}`);
  console.log(`Project: ${projectId ?? "fixture"}`);
  console.log(`Output: ${relativeToRepo(outputPath)}`);
  console.log(`Decisions: ${batch.decisions.length}`);
  if (!args.write) {
    console.log("\nDry run only. Re-run with --write after reviewing output.");
  }
}

function printHelp() {
  console.log(`Usage: node tool/organizer_intake/export_policy_gap_decisions_from_firestore.mjs [options]

Options:
  --date <YYYY-MM-DD>       Deterministic export date. Required.
  --env <dev|staging|prod>  Firebase environment from .firebaserc.
  --project <projectId>     Firebase project override.
  --emulator                Use Firestore emulator at 127.0.0.1:8080.
  --emulator-host <host>    Firestore emulator host.
  --fixture <path>          Read fixture JSON instead of Firestore.
  --source-label <label>    Label embedded in the output batch id.
  --output <path>           Output path override.
  --write                   Write the JSON export.
  --allow-empty             Permit writing an empty export.
  --allow-overwrite         Permit overwriting changed output.
  --check                   Compare generated export to the output path.
  --json                    Print machine-readable dry-run output.
`);
}

function slugify(value) {
  return String(value)
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "") || "source";
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

function fail(message) {
  console.error(message);
  process.exit(1);
}

function isMain() {
  return process.argv[1] &&
    import.meta.url === pathToFileURL(process.argv[1]).href;
}
