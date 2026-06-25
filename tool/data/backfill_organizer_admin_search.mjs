#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {createRequire} from "node:module";
import {isDeepStrictEqual} from "node:util";
import {fileURLToPath} from "node:url";

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
  const plan = await buildOrganizerAdminSearchRepairPlan(
    db,
    loadOrganizerAdminSearchProjectionBuilder(),
    {serverTimestamp: admin.firestore.FieldValue.serverTimestamp()}
  );

  if (args.json) {
    const summary = args.summaryOnly ?
      compactSummary(plan.summary) :
      plan.summary;
    console.log(JSON.stringify(summary, null, 2));
  } else {
    printSummary(plan.summary, {summaryOnly: args.summaryOnly});
  }

  if (!args.apply) {
    console.log("\nDry run only. Re-run with --apply to write repairs.");
    return;
  }

  await applyOrganizerAdminSearchRepairPlan(db, plan);
  console.log("\nApplied organizer admin search repairs.");
}

export async function buildOrganizerAdminSearchRepairPlan(
  firestore,
  buildOrganizerAdminSearchProjection,
  options = {}
) {
  const serverTimestamp = options.serverTimestamp ?? "SERVER_TIMESTAMP";
  const clubsSnap = await firestore.collection("clubs").get();
  const repairs = [];

  for (const clubDoc of clubsSnap.docs) {
    const club = clubDoc.data();
    const expectedAdminSearch = buildOrganizerAdminSearchProjection(
      clubDoc.id,
      club,
      serverTimestamp,
      "adminOrganizerSearchBackfill"
    );
    const current = pickOrganizerAdminSearchComparable(club.adminSearch);
    const expected =
      pickOrganizerAdminSearchComparable(expectedAdminSearch);
    if (!isDeepStrictEqual(current, expected)) {
      repairs.push({
        path: clubDoc.ref.path,
        clubId: clubDoc.id,
        current,
        expected,
        patch: {adminSearch: expectedAdminSearch},
      });
    }
  }

  const summaryRepairs = repairs.map(({patch: _patch, ...repair}) => repair);
  return {
    repairs,
    summary: {
      clubsScanned: clubsSnap.size,
      repairsNeeded: repairs.length,
      missingSearch: summaryRepairs.filter((repair) =>
        repair.current.tokens.length === 0
      ).length,
      staleSearch: summaryRepairs.filter((repair) =>
        repair.current.tokens.length > 0
      ).length,
      repairs: summaryRepairs,
    },
  };
}

export async function applyOrganizerAdminSearchRepairPlan(firestore, plan) {
  for (let i = 0; i < plan.repairs.length; i += 450) {
    const batch = firestore.batch();
    for (const repair of plan.repairs.slice(i, i + 450)) {
      batch.update(firestore.doc(repair.path), repair.patch);
    }
    await batch.commit();
  }
}

export function pickOrganizerAdminSearchComparable(adminSearch) {
  const tokens = Array.isArray(adminSearch?.tokens) ?
    adminSearch.tokens.filter((token) => typeof token === "string") :
    [];
  const sortKey = typeof adminSearch?.sortKey === "string" ?
    adminSearch.sortKey :
    null;
  return {tokens, sortKey};
}

function loadOrganizerAdminSearchProjectionBuilder() {
  try {
    return requireFromFunctions("./lib/admin/organizerAdminSearch.js")
      .buildOrganizerAdminSearchProjection;
  } catch (error) {
    throw new Error(
      "Could not load functions/lib/admin/organizerAdminSearch.js. " +
      "Run `npm --prefix functions run build` before this repair tool. " +
      `Original error: ${error.message}`
    );
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
    summaryOnly: false,
    help: false,
  };

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--apply") parsed.apply = true;
    else if (arg === "--allow-prod") parsed.allowProd = true;
    else if (arg === "--json") parsed.json = true;
    else if (arg === "--summary-only") parsed.summaryOnly = true;
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

function printHelp() {
  console.log(`Usage: node tool/data/backfill_organizer_admin_search.mjs [options]

Backfills server-owned clubs/{clubId}.adminSearch projections used by the
admin Organizers tab. The script is dry-run by default.

Options:
  --apply                 Write repairs. Default is dry-run.
  --allow-prod            Required with --apply against prod.
  --json                  Print summary as JSON.
  --summary-only          Omit per-document repair details from output.
  --env <dev|staging|prod> Resolve project id from .firebaserc.
  --project <id>          Firebase project id.
  --emulator              Use Firestore emulator at 127.0.0.1:8080.
  --emulator-host <host>  Use a custom Firestore emulator host.
  -h, --help              Show this help.
`);
}

function compactSummary(summary) {
  return {
    clubsScanned: summary.clubsScanned,
    repairsNeeded: summary.repairsNeeded,
    missingSearch: summary.missingSearch,
    staleSearch: summary.staleSearch,
  };
}

function printSummary(summary, {summaryOnly = false} = {}) {
  console.log("Organizer admin search repair plan");
  console.log(`Clubs scanned: ${summary.clubsScanned}`);
  console.log(`Repairs needed: ${summary.repairsNeeded}`);
  console.log(`Missing search projections: ${summary.missingSearch}`);
  console.log(`Stale search projections: ${summary.staleSearch}`);

  if (!summaryOnly && summary.repairs.length > 0) {
    console.log("\nRepairs:");
    for (const repair of summary.repairs.slice(0, 100)) {
      console.log(`- ${repair.path}: ${JSON.stringify(repair.expected)}`);
    }
    if (summary.repairs.length > 100) {
      console.log(`... ${summary.repairs.length - 100} more repairs`);
    }
  }
}

function isMain() {
  return process.argv[1] &&
    path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
}
