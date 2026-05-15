#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {createRequire} from "node:module";
import {fileURLToPath, pathToFileURL} from "node:url";
import {
  buildProfileDecisionMigrationPlan,
} from "./validate_profile_decision_migration.mjs";

const toolDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(toolDir, "..");
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
      "Refusing to backfill prod without --allow-prod. " +
      "Run a dry run first, then rerun with --apply --allow-prod."
    );
  }
  if (args.emulatorHost) {
    process.env.FIRESTORE_EMULATOR_HOST = args.emulatorHost;
  }

  const admin = requireFromFunctions("firebase-admin");
  admin.initializeApp({projectId});
  const firestore = admin.firestore();
  const plan = await buildProfileDecisionMigrationPlan(firestore);
  const backfillPlan = buildProfileDecisionBackfillPlan(plan);

  if (args.json) {
    console.log(JSON.stringify(backfillPlan.summary, null, 2));
  } else {
    printSummary(backfillPlan.summary);
  }

  if (!args.apply) {
    console.log("\nDry run only. Re-run with --apply to write backfill docs.");
    return;
  }
  if (backfillPlan.summary.validationErrorCount > 0) {
    throw new Error("Refusing to backfill while decision validation errors exist.");
  }

  await applyProfileDecisionBackfill(firestore, backfillPlan);
  console.log("\nApplied profile decision backfill.");
}

export function buildProfileDecisionBackfillPlan(plan) {
  const sourceByKey = new Map(
    plan.current.decisions.map((decision) => [
      decisionKey(decision.ownerId, decision.targetId),
      decision,
    ])
  );
  const writes = [];
  for (const item of [...plan.missingFuture, ...plan.staleFuture]) {
    const source = sourceByKey.get(item.key);
    if (!source) continue;
    writes.push({
      key: item.key,
      op: "set",
      reason: plan.missingFuture.includes(item) ? "missingFuture" : "staleFuture",
      currentPath: source.path,
      futurePath: item.futurePath,
      data: source.data,
    });
  }

  return {
    writes,
    summary: {
      currentDecisionCount: plan.summary.currentDecisionCount,
      futureDecisionCount: plan.summary.futureDecisionCount,
      writesNeeded: writes.length,
      missingFutureCount: plan.summary.missingFutureCount,
      staleFutureCount: plan.summary.staleFutureCount,
      extraFutureCount: plan.summary.extraFutureCount,
      validationErrorCount: plan.summary.validationErrorCount,
      readyToApply:
        plan.summary.validationErrorCount === 0 &&
        writes.length > 0,
      extraFuture: plan.extraFuture.slice(0, 100),
      validationErrors: plan.validationErrors.slice(0, 100),
    },
  };
}

export async function applyProfileDecisionBackfill(firestore, plan) {
  for (let i = 0; i < plan.writes.length; i += 450) {
    const batch = firestore.batch();
    for (const write of plan.writes.slice(i, i + 450)) {
      batch.set(firestore.doc(write.futurePath), write.data);
    }
    await batch.commit();
  }
}

function decisionKey(ownerId, targetId) {
  return `${ownerId}/${targetId}`;
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
  console.log("Profile decision backfill plan");
  console.log(`Current decisions: ${summary.currentDecisionCount}`);
  console.log(`Future decisions: ${summary.futureDecisionCount}`);
  console.log(`Writes needed: ${summary.writesNeeded}`);
  console.log(`Missing future docs: ${summary.missingFutureCount}`);
  console.log(`Stale future docs: ${summary.staleFutureCount}`);
  console.log(`Extra future docs: ${summary.extraFutureCount}`);
  console.log(`Validation errors: ${summary.validationErrorCount}`);
}

function printHelp() {
  console.log(`Usage: node tool/backfill_profile_decisions.mjs [options]

Dry-run-first backfill for the swipes -> profileDecisions storage migration.
The script copies missing or stale legacy swipes into profileDecisions. It never
deletes either path.

Options:
  --apply                 Write missing/stale future docs. Default is dry-run.
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
