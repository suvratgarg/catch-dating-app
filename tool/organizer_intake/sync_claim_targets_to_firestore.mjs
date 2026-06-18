#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {pathToFileURL} from "node:url";
import {
  applyFirestoreEmulatorHost,
  assertProdWriteAllowed,
  resolveFirebaseProjectId,
} from "../lib/firebase_project.mjs";
import {
  createFunctionsRequire,
  fromRepo,
  relativeToRepo,
} from "../lib/repo_paths.mjs";
import {
  actionSummary,
  buildClaimTargetSyncActions,
  summarizeActions,
} from "./lib/claim_target_sync_core.mjs";

const defaultPlanPath = fromRepo(
  "tool/organizer_intake/generated/organizer_claim_targets.json"
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

  const planPath = path.resolve(args.plan ?? defaultPlanPath);
  const plan = loadPlan(planPath);
  const projectId = args.fixture ?
    null :
    resolveFirebaseProjectId({env: args.env, project: args.project});

  assertProdWriteAllowed({
    env: args.env,
    projectId,
    project: args.project,
    apply: args.write,
    allowProd: args.allowProd,
    confirmProd: args.confirmProd,
    action: "sync organizer intake claim targets",
  });

  const existingDocs = args.fixture ?
    loadExistingDocsFixture(args.fixture) :
    await readExistingDocs({
      projectId,
      emulatorHost: args.emulatorHost,
      targets: plan.targets,
    });
  const actions = buildClaimTargetSyncActions(plan.targets, existingDocs);
  const summary = summarizeActions(actions);

  if (args.check && summary.writesNeeded > 0) {
    printSummary({args, projectId, planPath, summary, actions});
    fail(
      "Organizer claim targets are not synced. Run a dry run, review the " +
        "actions, then rerun with --write."
    );
  }

  if (args.json) {
    console.log(JSON.stringify({
      mode: args.write ? "write" : args.check ? "check" : "dry_run",
      projectId,
      fixture: args.fixture ? relativeToRepo(path.resolve(args.fixture)) : null,
      plan: relativeToRepo(planPath),
      summary,
      actions: actions.map(actionSummary),
    }, null, 2));
  } else {
    printSummary({args, projectId, planPath, summary, actions});
  }

  if (!args.write) return;
  if (summary.writesNeeded === 0) {
    console.log("No organizer claim target writes needed.");
    return;
  }
  const {admin, db} = initFirestore({projectId, emulatorHost: args.emulatorHost});
  const batch = db.batch();
  for (const action of actions) {
    if (action.status !== "create" && action.status !== "refresh") continue;
    batch.set(
      db.doc(action.path),
      convertFirestoreValues(admin, action.writeData),
      {merge: action.merge}
    );
  }
  await batch.commit();
  console.log(`Wrote ${summary.writesNeeded} organizer claim target updates.`);
}

function loadPlan(planPath) {
  const plan = JSON.parse(fs.readFileSync(planPath, "utf8"));
  if (plan.schemaVersion !== 1 || !Array.isArray(plan.targets)) {
    throw new Error(`Unsupported claim target plan: ${relativeToRepo(planPath)}`);
  }
  for (const target of plan.targets) {
    if (!target.path?.startsWith("clubs/")) {
      throw new Error(`Invalid claim target path: ${target.path}`);
    }
    if (!target.clubDocument || typeof target.clubDocument !== "object") {
      throw new Error(`Missing clubDocument for ${target.path}`);
    }
    if (target.claimState !== "unclaimed") {
      throw new Error(`${target.path}: claim targets must start unclaimed.`);
    }
  }
  return plan;
}

async function readExistingDocs({projectId, emulatorHost, targets}) {
  const {db} = initFirestore({projectId, emulatorHost});
  const snapshots = await Promise.all(
    targets.map((target) => db.doc(target.path).get())
  );
  return new Map(
    snapshots
      .filter((snapshot) => snapshot.exists)
      .map((snapshot) => [snapshot.ref.path, snapshot.data()])
  );
}

function initFirestore({projectId, emulatorHost}) {
  applyFirestoreEmulatorHost(emulatorHost);
  const requireFromFunctions = createFunctionsRequire();
  const admin = requireFromFunctions("firebase-admin");
  if (admin.apps.length === 0) {
    admin.initializeApp({projectId});
  }
  return {admin, db: admin.firestore()};
}

function loadExistingDocsFixture(fixturePath) {
  const payload = JSON.parse(fs.readFileSync(path.resolve(fixturePath), "utf8"));
  if (Array.isArray(payload)) {
    return new Map(payload.map((entry) => [entry.path, entry.data]));
  }
  if (payload && typeof payload === "object" && Array.isArray(payload.docs)) {
    return new Map(payload.docs.map((entry) => [entry.path, entry.data]));
  }
  if (payload && typeof payload === "object") {
    return new Map(Object.entries(payload));
  }
  throw new Error(`Unsupported fixture shape: ${fixturePath}`);
}

function convertFirestoreValues(admin, value) {
  if (Array.isArray(value)) {
    return value.map((nested) => convertFirestoreValues(admin, nested));
  }
  if (!value || typeof value !== "object") return value;
  const keys = Object.keys(value);
  if (
    keys.length === 2 &&
    keys.includes("_seconds") &&
    keys.includes("_nanoseconds") &&
    Number.isInteger(value._seconds) &&
    Number.isInteger(value._nanoseconds)
  ) {
    return new admin.firestore.Timestamp(value._seconds, value._nanoseconds);
  }
  return Object.fromEntries(
    Object.entries(value).map(([key, nested]) => [
      key,
      convertFirestoreValues(admin, nested),
    ])
  );
}

function parseArgs(argv) {
  const parsed = {
    allowProd: false,
    check: false,
    confirmProd: false,
    emulatorHost: null,
    env: null,
    fixture: null,
    help: false,
    json: false,
    plan: null,
    project: null,
    write: false,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--allow-prod") parsed.allowProd = true;
    else if (arg === "--check") parsed.check = true;
    else if (arg === "--confirm-prod") parsed.confirmProd = true;
    else if (arg === "--emulator") parsed.emulatorHost = "127.0.0.1:8080";
    else if (arg === "--json") parsed.json = true;
    else if (arg === "--write") parsed.write = true;
    else if (arg === "--emulator-host") parsed.emulatorHost = requiredValue(argv, ++index, arg);
    else if (arg === "--env") parsed.env = requiredValue(argv, ++index, arg);
    else if (arg === "--fixture") parsed.fixture = requiredValue(argv, ++index, arg);
    else if (arg === "--plan") parsed.plan = requiredValue(argv, ++index, arg);
    else if (arg === "--project") parsed.project = requiredValue(argv, ++index, arg);
    else fail(`Unknown argument: ${arg}`);
  }
  return parsed;
}

function requiredValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) fail(`${flag} requires a value.`);
  return value;
}

function printSummary({args, projectId, planPath, summary, actions}) {
  console.log("Organizer intake claim-target Firestore sync");
  console.log(`Mode: ${args.write ? "write" : args.check ? "check" : "dry run"}`);
  console.log(`Project: ${args.fixture ? "fixture" : projectId}`);
  console.log(`Plan: ${relativeToRepo(planPath)}`);
  console.log(`Targets: ${summary.targets}`);
  console.log(`Creates: ${summary.creates}`);
  console.log(`Refreshes: ${summary.refreshes}`);
  console.log(`Skipped owner-bound: ${summary.skippedOwnerBound}`);
  for (const action of actions) {
    console.log(`- ${action.status}: ${action.path} (${action.reason})`);
  }
  if (!args.write) {
    console.log("\nDry run only. Re-run with --write after reviewing actions.");
  }
}

function printHelp() {
  console.log(`Usage: node tool/organizer_intake/sync_claim_targets_to_firestore.mjs [options]

Syncs approved organizer-intake claim targets from
tool/organizer_intake/generated/organizer_claim_targets.json into Firestore
clubs/{entityId}. Missing docs are created. Existing unclaimed or claim-pending
docs only receive public-field refreshes. Owner-bound docs are skipped.

Options:
  --plan <path>            Claim target plan path.
  --env <dev|staging|prod> Resolve Firebase project id from .firebaserc.
  --project <id>           Firebase project id.
  --emulator               Use Firestore emulator at 127.0.0.1:8080.
  --emulator-host <host>   Use a custom Firestore emulator host.
  --fixture <path>         Read existing docs from a local fixture.
  --write                  Apply remote writes. Default is dry run.
  --check                  Fail when any create/refresh action is needed.
  --allow-prod             Permit prod writes after a reviewed dry run.
  --confirm-prod           Required with --allow-prod for prod writes.
  --json                   Print machine-readable output.
  -h, --help               Show this help.

Examples:
  node tool/organizer_intake/sync_claim_targets_to_firestore.mjs --env dev
  node tool/organizer_intake/sync_claim_targets_to_firestore.mjs --env dev --write
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
