#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {createRequire} from "node:module";
import {fileURLToPath, pathToFileURL} from "node:url";
import {
  buildProfileDecisionMigrationPlan,
  legacySourceMigration,
  readMigrationContract,
} from "./validate_profile_decision_migration.mjs";

const toolDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(toolDir, "../..");
const requireFromFunctions = createRequire(
  path.join(repoRoot, "functions/package.json")
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

  const projectId = resolveProjectId(args);
  if (args.apply && isProductionTarget(args, projectId) && !args.allowProd) {
    throw new Error(
      "Refusing to delete legacy swipes in prod without --allow-prod. " +
      "Run a dry run first, then rerun with --apply --allow-prod."
    );
  }
  if (args.emulatorHost) {
    process.env.FIRESTORE_EMULATOR_HOST = args.emulatorHost;
  }

  const admin = requireFromFunctions("firebase-admin");
  admin.initializeApp({projectId});
  const firestore = admin.firestore();
  const plan = await buildProfileDecisionMigrationPlan(
    firestore,
    {migration: legacySourceMigration(readMigrationContract())}
  );
  const retirementPlan = buildProfileDecisionRetirementPlan(plan, {
    projectId,
    apply: args.apply,
  });

  if (args.json) {
    console.log(JSON.stringify(retirementPlan.summary, null, 2));
  } else {
    printSummary(retirementPlan.summary);
  }

  if (!args.apply) {
    console.log("\nDry run only. Re-run with --apply to delete legacy swipes.");
    return;
  }
  if (!retirementPlan.summary.safeToDeleteLegacy) {
    throw new Error(
      "Refusing to delete legacy swipes before parity validation passes."
    );
  }

  await applyProfileDecisionRetirement(firestore, retirementPlan);
  console.log("\nDeleted legacy swipes profile decision documents.");
}

export function buildProfileDecisionRetirementPlan(plan, {
  projectId = null,
  apply = false,
} = {}) {
  const deleteDocs = plan.current.decisions.map((decision) => ({
    path: decision.path,
    key: `${decision.ownerId}/${decision.targetId}`,
  }));
  const safeToDeleteLegacy =
    plan.summary.validationErrorCount === 0 &&
    plan.summary.missingFutureCount === 0 &&
    plan.summary.staleFutureCount === 0;

  return {
    deleteDocs,
    summary: {
      mode: apply ? "apply" : "dry-run",
      projectId,
      legacyStoragePath: plan.summary.currentStoragePath,
      currentStoragePath: plan.summary.candidatePrimaryStoragePath,
      legacyDecisionCount: plan.summary.currentDecisionCount,
      currentDecisionCount: plan.summary.futureDecisionCount,
      deletesNeeded: deleteDocs.length,
      missingCurrentCount: plan.summary.missingFutureCount,
      staleCurrentCount: plan.summary.staleFutureCount,
      extraCurrentCount: plan.summary.extraFutureCount,
      validationErrorCount: plan.summary.validationErrorCount,
      safeToDeleteLegacy,
      sampleDeletes: deleteDocs.slice(0, 100),
      missingCurrent: plan.missingFuture.slice(0, 100),
      staleCurrent: plan.staleFuture.slice(0, 100),
      validationErrors: plan.validationErrors.slice(0, 100),
    },
  };
}

export async function applyProfileDecisionRetirement(firestore, plan) {
  for (let i = 0; i < plan.deleteDocs.length; i += 450) {
    const batch = firestore.batch();
    for (const doc of plan.deleteDocs.slice(i, i + 450)) {
      batch.delete(firestore.doc(doc.path));
    }
    await batch.commit();
  }
}

function parseArgs(argv) {
  const parsed = {
    env: null,
    project: null,
    emulatorHost: null,
    apply: false,
    allowProd: false,
    json: false,
    help: false,
  };

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--apply") parsed.apply = true;
    else if (arg === "--allow-prod") parsed.allowProd = true;
    else if (arg === "--json") parsed.json = true;
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

function isProductionTarget(parsed, projectId) {
  const firebaserc = readFirebaseRc();
  return parsed.env === "prod" || projectId === firebaserc.projects?.prod;
}

function readFirebaseRc() {
  return JSON.parse(
    fs.readFileSync(path.join(repoRoot, ".firebaserc"), "utf8")
  );
}

function printSummary(summary) {
  console.log("Legacy profile decision retirement plan");
  console.log(`Project: ${summary.projectId}`);
  console.log(`Legacy path: ${summary.legacyStoragePath}`);
  console.log(`Current path: ${summary.currentStoragePath}`);
  console.log(`Legacy decisions: ${summary.legacyDecisionCount}`);
  console.log(`Current decisions: ${summary.currentDecisionCount}`);
  console.log(`Deletes needed: ${summary.deletesNeeded}`);
  console.log(`Missing current docs: ${summary.missingCurrentCount}`);
  console.log(`Stale current docs: ${summary.staleCurrentCount}`);
  console.log(`Extra current docs: ${summary.extraCurrentCount}`);
  console.log(`Validation errors: ${summary.validationErrorCount}`);
  console.log(`Safe to delete legacy: ${summary.safeToDeleteLegacy ? "yes" : "no"}`);
}

function printHelp() {
  console.log(`Usage: node tool/data/retire_legacy_profile_decisions.mjs [options]

Dry-run-first cleanup for the swipes -> profileDecisions storage migration.
The script compares legacy swipes/{uid}/outgoing/{targetId} documents against
profileDecisions/{uid}/outgoing/{targetId}. It deletes legacy swipes only when
all legacy documents validate and each one has a matching current document.

Options:
  --apply                 Delete legacy swipes. Default is dry-run.
  --allow-prod            Required with --apply against prod.
  --json                  Print compact summary as JSON.
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
