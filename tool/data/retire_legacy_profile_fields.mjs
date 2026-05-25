#!/usr/bin/env node
import {
  isProductionTarget,
  loadFirebaseAdmin,
  resolveProjectId,
} from "../demo/demo_ops_core.mjs";

const admin = loadFirebaseAdmin();

const legacyFields = [
  "photoUrls",
  "photoThumbnailUrls",
  "photoPrompts",
  "paceMinSecsPerKm",
  "paceMaxSecsPerKm",
  "preferredDistances",
  "runningReasons",
  "preferredRunTimes",
  "runPreferencesVersion",
];

if (isMain()) {
  await main(process.argv.slice(2));
}

export async function main(argv = []) {
  const args = parseArgs(argv);
  if (args.help) {
    printHelp();
    return;
  }

  const projectId = resolveProjectId(args);
  if (isProductionTarget({env: args.env, projectId}) && !args.allowProd) {
    throw new Error(
      "Refusing to touch prod without --allow-prod. " +
      "Run a dry-run first, then pass --apply --allow-prod intentionally."
    );
  }
  if (args.emulatorHost) {
    process.env.FIRESTORE_EMULATOR_HOST = args.emulatorHost;
  }

  admin.initializeApp({projectId});
  const db = admin.firestore();
  const batchSize = Number(args.batchSize ?? 400);
  const summary = {
    mode: args.apply ? "apply" : "dry-run",
    projectId,
    collections: {},
    batches: 0,
  };

  for (const collection of ["users", "publicProfiles"]) {
    const result = await scanCollection({
      db,
      collection,
      apply: Boolean(args.apply),
      batchSize,
    });
    summary.collections[collection] = result;
    summary.batches += result.batches;
  }

  console.log(JSON.stringify(summary, null, 2));
}

async function scanCollection({
  db,
  collection,
  apply,
  batchSize,
}) {
  let scanned = 0;
  let changed = 0;
  let backfilledActivityPreferences = 0;
  let batches = 0;
  let batch = db.batch();
  let pending = 0;

  const snapshot = await db.collection(collection).get();
  for (const doc of snapshot.docs) {
    scanned += 1;
    const data = doc.data();
    const patch = legacyFieldRetirementPatch(data);
    if (Object.keys(patch).length === 0) continue;

    changed += 1;
    if (patch.activityPreferences) backfilledActivityPreferences += 1;
    console.log(
      `${apply ? "[update]" : "[dry-run]"} ${collection}/${doc.id}`
    );

    if (!apply) continue;
    batch.update(doc.ref, patch);
    pending += 1;
    if (pending >= batchSize) {
      await batch.commit();
      batches += 1;
      batch = db.batch();
      pending = 0;
    }
  }

  if (apply && pending > 0) {
    await batch.commit();
    batches += 1;
  }

  return {scanned, changed, backfilledActivityPreferences, batches};
}

function legacyFieldRetirementPatch(data) {
  const patch = {};
  const running = runningPreferencesPatch(data);
  if (running) {
    patch.activityPreferences = {
      ...(isRecord(data.activityPreferences) ? data.activityPreferences : {}),
      running,
    };
  }

  for (const field of legacyFields) {
    if (Object.hasOwn(data, field)) {
      patch[field] = admin.firestore.FieldValue.delete();
    }
  }
  return patch;
}

function runningPreferencesPatch(data) {
  const activityPreferences = isRecord(data.activityPreferences) ?
    data.activityPreferences :
    {};
  if (isRecord(activityPreferences.running)) return null;

  const hasLegacy = [
    "paceMinSecsPerKm",
    "paceMaxSecsPerKm",
    "preferredDistances",
    "runningReasons",
    "preferredRunTimes",
    "runPreferencesVersion",
  ].some((field) => Object.hasOwn(data, field));
  if (!hasLegacy) return null;

  return {
    paceMinSecsPerKm: numberOrDefault(data.paceMinSecsPerKm, 300),
    paceMaxSecsPerKm: numberOrDefault(data.paceMaxSecsPerKm, 420),
    preferredDistances: stringArray(data.preferredDistances),
    runningReasons: stringArray(data.runningReasons),
    preferredRunTimes: stringArray(data.preferredRunTimes),
    version: numberOrDefault(data.runPreferencesVersion, 0),
  };
}

function numberOrDefault(value, fallback) {
  return typeof value === "number" && Number.isFinite(value) ?
    value :
    fallback;
}

function stringArray(value) {
  return Array.isArray(value) ?
    value.filter((item) => typeof item === "string") :
    [];
}

function isRecord(value) {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function parseArgs(argv) {
  const args = {};
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--help" || arg === "-h") args.help = true;
    else if (arg === "--apply") args.apply = true;
    else if (arg === "--allow-prod") args.allowProd = true;
    else if (arg === "--env") args.env = argv[++index];
    else if (arg === "--project") args.project = argv[++index];
    else if (arg === "--emulator-host") args.emulatorHost = argv[++index];
    else if (arg === "--batch-size") args.batchSize = argv[++index];
    else throw new Error(`Unknown argument: ${arg}`);
  }
  return args;
}

function printHelp() {
  console.log(`
Usage:
  node tool/data/retire_legacy_profile_fields.mjs --env dev
  node tool/data/retire_legacy_profile_fields.mjs --env dev --apply
  node tool/data/retire_legacy_profile_fields.mjs --env prod --apply --allow-prod

Backfills users/publicProfiles activityPreferences.running from legacy root
running fields when needed, then removes legacy profile photo arrays and
root-level running preference fields. The script is dry-run by default.
`.trim());
}

function isMain() {
  return import.meta.url === `file://${process.argv[1]}`;
}
