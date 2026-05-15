#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {createRequire} from "node:module";
import {isDeepStrictEqual} from "node:util";
import {fileURLToPath, pathToFileURL} from "node:url";
import {
  schemaErrorMessages,
  validateSwipeDocument,
} from "./generated/schema_contract_validators.mjs";

const toolDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(toolDir, "..");
const requireFromFunctions = createRequire(
  path.join(repoRoot, "functions/package.json")
);
const migrationContractPath = path.join(
  repoRoot,
  "contracts/migrations/swipes_to_profile_decisions.json"
);

if (isMain()) {
  await main();
}

export async function main(argv = process.argv.slice(2)) {
  const args = parseArgs(argv);
  if (args.help) {
    printHelp();
    return;
  }
  if (args.emulatorHost) {
    process.env.FIRESTORE_EMULATOR_HOST = args.emulatorHost;
  }

  const projectId = resolveProjectId(args);
  const admin = requireFromFunctions("firebase-admin");
  admin.initializeApp({projectId});

  const plan = await buildProfileDecisionMigrationPlan(admin.firestore());
  if (args.json) {
    console.log(JSON.stringify(plan.summary, null, 2));
  } else {
    printSummary(plan);
  }

  if (args.requireParity && !plan.summary.readyForPrimaryCutover) {
    process.exitCode = 1;
  }
}

export async function buildProfileDecisionMigrationPlan(
  firestore,
  {
    migration = readMigrationContract(),
    validator = validateSwipeDocument,
  } = {}
) {
  const currentPath = parseDecisionPath(migration.currentStoragePath);
  const futurePath = parseDecisionPath(migration.candidatePrimaryStoragePath);
  const [current, future] = await Promise.all([
    listDecisionDocs(firestore, currentPath),
    listDecisionDocs(firestore, futurePath),
  ]);

  const currentByKey = mapDecisionDocs(current.decisions);
  const futureByKey = mapDecisionDocs(future.decisions);
  const validationErrors = [
    ...validateDecisionDocs("current", current.decisions, validator),
    ...validateDecisionDocs("future", future.decisions, validator),
  ];
  const missingFuture = [];
  const staleFuture = [];
  const extraFuture = [];

  for (const [key, source] of currentByKey.entries()) {
    const target = futureByKey.get(key);
    if (!target) {
      missingFuture.push({
        key,
        currentPath: source.path,
        futurePath: decisionPath(futurePath, source.ownerId, source.targetId),
      });
      continue;
    }
    if (!decisionDataEqual(source.data, target.data)) {
      staleFuture.push({
        key,
        currentPath: source.path,
        futurePath: target.path,
        current: normalizeForCompare(source.data),
        future: normalizeForCompare(target.data),
      });
    }
  }

  for (const [key, target] of futureByKey.entries()) {
    if (!currentByKey.has(key)) {
      extraFuture.push({
        key,
        futurePath: target.path,
      });
    }
  }

  return {
    current,
    future,
    missingFuture,
    staleFuture,
    extraFuture,
    validationErrors,
    summary: {
      logicalName: migration.logicalName,
      currentStoragePath: migration.currentStoragePath,
      candidatePrimaryStoragePath: migration.candidatePrimaryStoragePath,
      currentOwnerDocsScanned: current.ownerDocsScanned,
      futureOwnerDocsScanned: future.ownerDocsScanned,
      currentOwnersWithDecisions: current.ownersWithDecisions,
      futureOwnersWithDecisions: future.ownersWithDecisions,
      currentDecisionCount: current.decisions.length,
      futureDecisionCount: future.decisions.length,
      missingFutureCount: missingFuture.length,
      staleFutureCount: staleFuture.length,
      extraFutureCount: extraFuture.length,
      validationErrorCount: validationErrors.length,
      readyForBackfill: validationErrors.length === 0,
      readyForPrimaryCutover:
        validationErrors.length === 0 &&
        missingFuture.length === 0 &&
        staleFuture.length === 0 &&
        extraFuture.length === 0,
      missingFuture: missingFuture.slice(0, 100),
      staleFuture: staleFuture.slice(0, 100),
      extraFuture: extraFuture.slice(0, 100),
      validationErrors: validationErrors.slice(0, 100),
    },
  };
}

async function listDecisionDocs(firestore, pathParts) {
  const ownerSnap = await firestore.collection(pathParts.rootCollection).get();
  const decisions = [];
  let ownersWithDecisions = 0;

  for (const ownerDoc of ownerSnap.docs) {
    const outgoingSnap = await firestore
      .collection(pathParts.rootCollection)
      .doc(ownerDoc.id)
      .collection(pathParts.outgoingCollection)
      .get();
    if (outgoingSnap.size > 0) ownersWithDecisions += 1;
    for (const decisionDoc of outgoingSnap.docs) {
      decisions.push({
        ownerId: ownerDoc.id,
        targetId: decisionDoc.id,
        path: decisionPath(pathParts, ownerDoc.id, decisionDoc.id),
        data: decisionDoc.data(),
      });
    }
  }

  return {
    rootCollection: pathParts.rootCollection,
    outgoingCollection: pathParts.outgoingCollection,
    ownerDocsScanned: ownerSnap.size,
    ownersWithDecisions,
    decisions,
  };
}

function validateDecisionDocs(kind, decisions, validator) {
  const errors = [];
  for (const decision of decisions) {
    const payload = normalizeForCompare(decision.data);
    if (!validator(payload)) {
      errors.push({
        kind,
        path: decision.path,
        errors: schemaErrorMessages(validator),
      });
    }
    if (payload.swiperId !== decision.ownerId) {
      errors.push({
        kind,
        path: decision.path,
        errors: [
          `/swiperId should match owner id ${decision.ownerId}`,
        ],
      });
    }
    if (payload.targetId !== decision.targetId) {
      errors.push({
        kind,
        path: decision.path,
        errors: [
          `/targetId should match document id ${decision.targetId}`,
        ],
      });
    }
  }
  return errors;
}

function mapDecisionDocs(decisions) {
  return new Map(
    decisions.map((decision) => [
      decisionKey(decision.ownerId, decision.targetId),
      decision,
    ])
  );
}

function decisionKey(ownerId, targetId) {
  return `${ownerId}/${targetId}`;
}

function decisionPath(pathParts, ownerId, targetId) {
  return `${pathParts.rootCollection}/${ownerId}/` +
    `${pathParts.outgoingCollection}/${targetId}`;
}

function decisionDataEqual(left, right) {
  return isDeepStrictEqual(
    normalizeForCompare(left),
    normalizeForCompare(right)
  );
}

export function normalizeForCompare(value) {
  if (Array.isArray(value)) {
    return value.map((item) => normalizeForCompare(item));
  }
  if (!value || typeof value !== "object") return value;

  const timestamp = timestampParts(value);
  if (timestamp) return timestamp;

  return Object.fromEntries(
    Object.keys(value)
      .filter((key) => value[key] !== undefined)
      .sort()
      .map((key) => [key, normalizeForCompare(value[key])])
  );
}

function timestampParts(value) {
  const seconds = numberOrNull(value._seconds, value.seconds);
  const nanoseconds = numberOrNull(value._nanoseconds, value.nanoseconds);
  if (seconds === null || nanoseconds === null) return null;
  if (
    typeof value.toDate !== "function" &&
    !("_seconds" in value) &&
    !("seconds" in value)
  ) {
    return null;
  }
  return {_seconds: seconds, _nanoseconds: nanoseconds};
}

function numberOrNull(...values) {
  for (const value of values) {
    if (typeof value === "number") return value;
  }
  return null;
}

function parseDecisionPath(pathTemplate) {
  const parts = pathTemplate.split("/");
  if (
    parts.length !== 4 ||
    !parts[1].startsWith("{") ||
    !parts[1].endsWith("}") ||
    !parts[3].startsWith("{") ||
    !parts[3].endsWith("}")
  ) {
    throw new Error(
      `Expected path template root/{owner}/outgoing/{target}, got: ` +
      pathTemplate
    );
  }
  return {
    rootCollection: parts[0],
    ownerParam: parts[1].slice(1, -1),
    outgoingCollection: parts[2],
    targetParam: parts[3].slice(1, -1),
  };
}

function readMigrationContract() {
  return JSON.parse(fs.readFileSync(migrationContractPath, "utf8"));
}

function parseArgs(argv) {
  const parsed = {
    env: null,
    project: null,
    emulatorHost: null,
    json: false,
    requireParity: false,
    help: false,
  };

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--json") parsed.json = true;
    else if (arg === "--require-parity") parsed.requireParity = true;
    else if (arg === "--emulator") parsed.emulatorHost = "127.0.0.1:8080";
    else if (arg === "--emulator-host") {
      parsed.emulatorHost = requireValue(argv, ++i, arg);
    } else if (arg === "--env") {
      parsed.env = requireValue(argv, ++i, arg);
    } else if (arg === "--project") {
      parsed.project = requireValue(argv, ++i, arg);
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

function resolveProjectId(parsed) {
  if (parsed.project) return parsed.project;
  if (parsed.env) {
    const firebaserc = readFirebaseRc();
    const project = firebaserc.projects?.[parsed.env];
    if (!project) {
      throw new Error(`No Firebase project alias found for env: ${parsed.env}`);
    }
    return project;
  }
  return process.env.GCLOUD_PROJECT ||
    process.env.GOOGLE_CLOUD_PROJECT ||
    "catchdates-dev";
}

function readFirebaseRc() {
  return JSON.parse(
    fs.readFileSync(path.join(repoRoot, ".firebaserc"), "utf8")
  );
}

function printSummary(plan) {
  const summary = plan.summary;
  console.log("Profile decision storage migration validation");
  console.log(`Current path: ${summary.currentStoragePath}`);
  console.log(`Future path: ${summary.candidatePrimaryStoragePath}`);
  console.log(`Current decisions: ${summary.currentDecisionCount}`);
  console.log(`Future decisions: ${summary.futureDecisionCount}`);
  console.log(`Missing future docs: ${summary.missingFutureCount}`);
  console.log(`Stale future docs: ${summary.staleFutureCount}`);
  console.log(`Extra future docs: ${summary.extraFutureCount}`);
  console.log(`Validation errors: ${summary.validationErrorCount}`);
  console.log(
    `Ready for primary cutover: ${summary.readyForPrimaryCutover ? "yes" : "no"}`
  );

  printItems("Missing future docs", plan.missingFuture);
  printItems("Stale future docs", plan.staleFuture);
  printItems("Extra future docs", plan.extraFuture);
  printItems("Validation errors", plan.validationErrors);
}

function printItems(label, items) {
  if (items.length === 0) return;
  console.log(`\n${label}:`);
  for (const item of items.slice(0, 100)) {
    console.log(`- ${JSON.stringify(item)}`);
  }
  if (items.length > 100) {
    console.log(`... ${items.length - 100} more`);
  }
}

function printHelp() {
  console.log(`Usage: node tool/validate_profile_decision_migration.mjs [options]

Dry-run validator for the eventual swipes -> profileDecisions storage rename.
The script reads both paths, validates decision documents against the generated
schema, and compares counts plus document contents. It never writes data.

Options:
  --require-parity        Exit non-zero unless current and future paths match.
  --json                  Print summary as JSON.
  --env <dev|staging|prod> Resolve project id from .firebaserc.
  --project <id>          Firebase project id.
  --emulator              Use Firestore emulator at 127.0.0.1:8080.
  --emulator-host <host>  Use a custom Firestore emulator host.
  -h, --help              Show this help.
`);
}

function isMain() {
  return process.argv[1] &&
    import.meta.url === pathToFileURL(process.argv[1]).href;
}
