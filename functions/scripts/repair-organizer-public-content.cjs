#!/usr/bin/env node
"use strict";

const fs = require("node:fs");
const path = require("node:path");

const usage = `Usage: node scripts/repair-organizer-public-content.cjs --project <id> [options]

Plans and applies the cleanup of operator content in organizer public fields
(organizers/{id}.description, publicPage SEO copy, publicProfile and
publicSources). Fit notes, evidence checklists, claim/index facts and sources
without a distinct public link are removed mechanically. Intake wording in
prose fields needs a reviewed replacement value. Dry run is the default and
never writes. Build first: npm --prefix functions run build.

Options:
  --project <id>          Firebase project id (required).
  --organizer <id>        Limit the scan to organizers/<id>.
  --replacements <file>   JSON {"organizers/<id>": {"<field>": value}} with
                          reviewed values for description,
                          publicPage.seoTitle, publicPage.seoDescription,
                          publicProfile.headline, publicProfile.summary,
                          publicProfile.sourceSummary, publicProfile.facts,
                          publicProfile.eventEvidence or publicSources.
  --check                 Exit 1 while any scanned organizer needs a repair.
  --apply                 Write the reviewed plan. Requires --plan-hash.
  --plan-hash <sha256>    planHash printed by the reviewed dry run.
  --allow-prod            Required with --apply against the prod project.
  -h, --help              Show this help.
`;

function parseArgs(argv) {
  const args = {
    project: null,
    organizer: null,
    replacements: null,
    check: false,
    apply: false,
    planHash: null,
    allowProd: false,
    help: false,
  };
  const valueFlags = {
    "--project": "project",
    "--organizer": "organizer",
    "--replacements": "replacements",
    "--plan-hash": "planHash",
  };
  for (let index = 0; index < argv.length; index++) {
    const flag = argv[index];
    if (flag === "--help" || flag === "-h") args.help = true;
    else if (flag === "--check") args.check = true;
    else if (flag === "--apply") args.apply = true;
    else if (flag === "--allow-prod") args.allowProd = true;
    else if (valueFlags[flag]) {
      const value = argv[++index];
      if (!value || value.startsWith("--")) {
        throw new Error(`${flag} requires a value.`);
      }
      args[valueFlags[flag]] = value;
    } else throw new Error(`Unknown argument: ${flag}`);
  }
  if (args.help) return args;
  if (typeof args.project !== "string" || !/^[a-z0-9-]+$/.test(args.project)) {
    throw new Error("Provide an explicit --project id.");
  }
  if (args.organizer !== null && !/^[A-Za-z0-9_-]+$/.test(args.organizer)) {
    throw new Error("--organizer must be an organizer document id.");
  }
  if (args.apply && args.check) {
    throw new Error("Use --check or --apply, not both.");
  }
  if (args.apply && !args.planHash) {
    throw new Error("--apply requires --plan-hash from a reviewed dry run.");
  }
  return args;
}

function prodProjectId(
  firebaseRcPath = path.resolve(__dirname, "../../.firebaserc")
) {
  try {
    return JSON.parse(fs.readFileSync(firebaseRcPath, "utf8")).projects?.prod ??
      null;
  } catch {
    return null;
  }
}

function loadRepairPlanner() {
  try {
    return require("../lib/organizers/organizerPublicContentRepair");
  } catch (error) {
    throw new Error(
      "Could not load lib/organizers/organizerPublicContentRepair.js. " +
        `Run npm --prefix functions run build first. ${error.message}`
    );
  }
}

// Reviewed JSON carries Firestore timestamps as {_seconds, _nanoseconds}.
function withTimestamps(value, Timestamp) {
  if (Array.isArray(value)) {
    return value.map((item) => withTimestamps(item, Timestamp));
  }
  if (!value || typeof value !== "object") return value;
  const keys = Object.keys(value).sort();
  if (keys.length === 2 && keys[0] === "_nanoseconds" &&
      keys[1] === "_seconds") {
    return new Timestamp(value._seconds, value._nanoseconds);
  }
  return Object.fromEntries(Object.entries(value).map(([key, nested]) =>
    [key, withTimestamps(nested, Timestamp)]));
}

function loadReplacements(file, Timestamp) {
  if (!file) return {};
  const parsed = JSON.parse(fs.readFileSync(path.resolve(file), "utf8"));
  if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) {
    throw new Error("--replacements must be a JSON object keyed by path.");
  }
  for (const [docPath, fields] of Object.entries(parsed)) {
    if (!/^organizers\/[A-Za-z0-9_-]+$/.test(docPath) || !fields ||
        typeof fields !== "object" || Array.isArray(fields)) {
      throw new Error(`Invalid replacement entry: ${docPath}`);
    }
  }
  return withTimestamps(parsed, Timestamp);
}

async function readOrganizers(db, organizerId) {
  if (organizerId) {
    const snapshot = await db.collection("organizers").doc(organizerId).get();
    return snapshot.exists ? [snapshot] : [];
  }
  return (await db.collection("organizers").get()).docs;
}

function needsRepair(plan) {
  return Object.keys(plan.patch).length > 0 ||
    plan.remainingIssues.length > 0 ||
    plan.schemaRegressions.length > 0;
}

async function run(argv, {db, prodProject, Timestamp, log = console.log}) {
  const args = parseArgs(argv);
  if (args.help) {
    log(usage);
    return 0;
  }
  if (args.apply && args.project === prodProject && !args.allowProd) {
    throw new Error(
      "Refusing to write prod without --allow-prod. Review the dry run and " +
        "get owner approval first."
    );
  }
  const {
    organizerPublicContentPlanSetHash,
    planOrganizerPublicContentRepair,
  } = loadRepairPlanner();
  const replacements = loadReplacements(args.replacements, Timestamp);
  const snapshots = await readOrganizers(db, args.organizer);
  const scannedPaths = new Set(snapshots.map((snapshot) => snapshot.ref.path));
  for (const docPath of Object.keys(replacements)) {
    if (!scannedPaths.has(docPath)) {
      throw new Error(`Replacement target was not scanned: ${docPath}`);
    }
  }
  const plans = snapshots.map((snapshot) => planOrganizerPublicContentRepair(
    snapshot.ref.path,
    snapshot.data(),
    replacements[snapshot.ref.path] ?? {}
  ));
  const pending = plans.filter(needsRepair);
  const blocked = pending.filter((plan) =>
    plan.remainingIssues.length > 0 || plan.schemaRegressions.length > 0);
  const planHash = organizerPublicContentPlanSetHash(pending);
  log(JSON.stringify({
    projectId: args.project,
    mode: args.apply ? "apply" : args.check ? "check" : "dry_run",
    scanned: plans.length,
    clean: plans.length - pending.length,
    pending: pending.length,
    blocked: blocked.map((plan) => plan.path),
    planHash,
    plans: pending,
  }, null, 2));

  if (args.check) return pending.length > 0 ? 1 : 0;
  if (!args.apply) {
    log("Dry run only. Nothing was written.");
    return 0;
  }
  if (blocked.length > 0) {
    throw new Error(
      "Refusing to apply while organizers still have intake wording or " +
        `contract regressions: ${blocked.map((plan) => plan.path).join(", ")}`
    );
  }
  if (args.planHash !== planHash) {
    throw new Error(
      "--plan-hash does not match the current plan. Re-run the dry run and " +
        "review it again."
    );
  }
  let applied = 0;
  for (const plan of pending) {
    if (Object.keys(plan.patch).length === 0) continue;
    await db.runTransaction(async (tx) => {
      const ref = db.doc(plan.path);
      const snapshot = await tx.get(ref);
      const current = snapshot.exists ?
        planOrganizerPublicContentRepair(
          plan.path,
          snapshot.data(),
          replacements[plan.path] ?? {}
        ) :
        null;
      if (!current || current.hash !== plan.hash) {
        throw new Error(
          `${plan.path} changed after the reviewed dry run; nothing more ` +
            "was written. Re-run the dry run."
        );
      }
      tx.update(ref, plan.patch);
    });
    applied++;
  }
  log(`Applied ${applied} organizer public-content repairs. ` +
    "Re-run with --check to verify.");
  return 0;
}

async function main(argv = process.argv.slice(2)) {
  const args = parseArgs(argv);
  if (args.help) {
    console.log(usage);
    return;
  }
  const admin = require("firebase-admin");
  const app = admin.initializeApp({projectId: args.project});
  try {
    process.exitCode = await run(argv, {
      db: app.firestore(),
      prodProject: prodProjectId(),
      Timestamp: admin.firestore.Timestamp,
    });
  } finally {
    await app.delete();
  }
}

if (require.main === module) {
  main().catch((error) => {
    console.error(error.message);
    process.exitCode = 1;
  });
}

module.exports = {main, parseArgs, prodProjectId, run};
