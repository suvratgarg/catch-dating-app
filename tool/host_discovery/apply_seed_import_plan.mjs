#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {createRequire} from "node:module";
import {fileURLToPath} from "node:url";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(scriptDir, "..", "..");
const defaultPlanPath = path.join(
  scriptDir,
  "generated",
  "firestore_seed_import_plan.json"
);
const prodProjectId = "catch-dating-app-64e51";

const args = parseArgs(process.argv.slice(2));
if (args.help) {
  printHelp();
  process.exit(0);
}

if (!args.project) {
  fail("Missing required --project <firebase-project-id>.");
}

if (args.project === prodProjectId) {
  if (!args.allowProd || args.confirmProdProject !== prodProjectId) {
    fail(
      `Prod imports require --allow-prod --confirm-prod-project ${prodProjectId}.`
    );
  }
}

const planPath = path.resolve(repoRoot, args.plan ?? defaultPlanPath);
const plan = readJson(planPath);
if (plan.schemaVersion !== 1 || !Array.isArray(plan.writes)) {
  fail(`Unsupported import plan shape: ${relative(planPath)}`);
}

if (args.write && plan.applyStatus !== "dry_run_only") {
  fail(
    `Refusing to write a plan whose applyStatus is not dry_run_only: ${plan.applyStatus}`
  );
}

const writes = plan.writes;
if (writes.length === 0) {
  console.log("Host discovery import plan has no writes.");
  process.exit(0);
}

const {admin, db} = initFirestore(args.project);
const existing = await preflightExistingDocs(db, writes);
if (existing.length > 0 && !args.allowOverwrite) {
  fail(
    [
      "Preflight found existing target documents; rerun with --allow-overwrite only after review.",
      ...existing.map((pathValue) => `- ${pathValue}`),
    ].join("\n")
  );
}

if (existing.length > 0) {
  const unsafe = await preflightClaimedDocs(db, existing);
  if (unsafe.length > 0) {
    fail(
      [
        "Refusing to overwrite claimed or owner-managed club documents.",
        ...unsafe.map((pathValue) => `- ${pathValue}`),
      ].join("\n")
    );
  }
}

if (!args.write) {
  console.log(
    JSON.stringify(
      {
        mode: "dry_run",
        projectId: args.project,
        plan: relative(planPath),
        totalWrites: writes.length,
        existingTargets: existing,
        writes: writes.map((write) => ({
          op: write.op,
          path: write.path,
          merge: Boolean(write.merge),
          sourceFile: write.sourceFile,
        })),
      },
      null,
      2
    )
  );
  process.exit(0);
}

const batch = db.batch();
for (const write of writes) {
  if (write.op !== "set") {
    fail(`Unsupported write op ${write.op} for ${write.path}`);
  }
  const ref = db.doc(write.path);
  batch.set(ref, convertFirestoreValues(admin, write.data), {
    merge: Boolean(write.merge),
  });
}

await batch.commit();
console.log(
  JSON.stringify(
    {
      mode: "write",
      projectId: args.project,
      plan: relative(planPath),
      totalWrites: writes.length,
      overwrittenTargets: existing,
    },
    null,
    2
  )
);

function initFirestore(projectId) {
  const requireFromFunctions = createRequire(
    path.join(repoRoot, "functions", "package.json")
  );
  const admin = requireFromFunctions("firebase-admin");
  if (admin.apps.length === 0) {
    admin.initializeApp({projectId});
  }
  return {admin, db: admin.firestore()};
}

async function preflightExistingDocs(db, writesToCheck) {
  const snapshots = await Promise.all(
    writesToCheck.map((write) => db.doc(write.path).get())
  );
  return snapshots
    .filter((snapshot) => snapshot.exists)
    .map((snapshot) => snapshot.ref.path)
    .sort();
}

async function preflightClaimedDocs(db, existingPaths) {
  const clubPaths = existingPaths.filter((pathValue) =>
    pathValue.startsWith("clubs/")
  );
  const snapshots = await Promise.all(
    clubPaths.map((pathValue) => db.doc(pathValue).get())
  );
  return snapshots
    .filter((snapshot) => {
      const claimState = snapshot.get("claim.state");
      const ownershipState = snapshot.get("ownership.state");
      const ownerUserId = snapshot.get("ownerUserId");
      const hostUserId = snapshot.get("hostUserId");
      return (
        claimState === "claimed" ||
        ownershipState === "claimed" ||
        Boolean(ownerUserId) ||
        Boolean(hostUserId)
      );
    })
    .map((snapshot) => snapshot.ref.path)
    .sort();
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
    allowOverwrite: false,
    allowProd: false,
    confirmProdProject: null,
    help: false,
    plan: null,
    project: null,
    write: false,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--write") parsed.write = true;
    else if (arg === "--allow-overwrite") parsed.allowOverwrite = true;
    else if (arg === "--allow-prod") parsed.allowProd = true;
    else if (arg === "--project") parsed.project = requiredValue(argv, ++index, arg);
    else if (arg === "--plan") parsed.plan = requiredValue(argv, ++index, arg);
    else if (arg === "--confirm-prod-project") {
      parsed.confirmProdProject = requiredValue(argv, ++index, arg);
    } else {
      fail(`Unknown argument: ${arg}`);
    }
  }

  return parsed;
}

function requiredValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) {
    fail(`${flag} requires a value.`);
  }
  return value;
}

function readJson(file) {
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

function relative(file) {
  return path.relative(repoRoot, file);
}

function fail(message) {
  console.error(message);
  process.exit(1);
}

function printHelp() {
  console.log(`Usage:
  node tool/host_discovery/apply_seed_import_plan.mjs --project <id>
  node tool/host_discovery/apply_seed_import_plan.mjs --project <id> --write

Options:
  --project <id>                 Firebase project id to read/write.
  --plan <path>                  Import plan path. Defaults to generated plan.
  --write                        Commit the plan. Omit for dry-run preview.
  --allow-overwrite              Permit overwriting existing unclaimed docs.
  --allow-prod                   Permit prod writes when combined with confirmation.
  --confirm-prod-project <id>    Must equal ${prodProjectId} for prod writes.
`);
}
