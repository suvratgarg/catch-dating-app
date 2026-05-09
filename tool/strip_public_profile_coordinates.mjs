#!/usr/bin/env node
import {
  isProductionTarget,
  loadFirebaseAdmin,
  resolveProjectId,
} from "./demo_ops_core.mjs";

const admin = loadFirebaseAdmin();

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
  let scanned = 0;
  let changed = 0;
  let batches = 0;
  let batch = db.batch();
  let pendingWrites = 0;

  const snapshot = await db.collection("publicProfiles").get();
  for (const doc of snapshot.docs) {
    scanned += 1;
    const data = doc.data();
    if (!("latitude" in data) && !("longitude" in data)) continue;
    changed += 1;

    console.log(
      `${args.apply ? "[update]" : "[dry-run]"} publicProfiles/${doc.id}`
    );

    if (!args.apply) continue;
    batch.update(doc.ref, {
      latitude: admin.firestore.FieldValue.delete(),
      longitude: admin.firestore.FieldValue.delete(),
    });
    pendingWrites += 1;

    if (pendingWrites >= batchSize) {
      await batch.commit();
      batches += 1;
      batch = db.batch();
      pendingWrites = 0;
    }
  }

  if (args.apply && pendingWrites > 0) {
    await batch.commit();
    batches += 1;
  }

  console.log(JSON.stringify({
    mode: args.apply ? "apply" : "dry-run",
    projectId,
    scanned,
    changed,
    batches,
  }, null, 2));
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
  node tool/strip_public_profile_coordinates.mjs --env dev
  node tool/strip_public_profile_coordinates.mjs --env dev --apply
  node tool/strip_public_profile_coordinates.mjs --env prod --apply --allow-prod

Removes legacy latitude/longitude fields from publicProfiles/{uid}. The script
is dry-run by default.
`.trim());
}

function isMain() {
  return import.meta.url === `file://${process.argv[1]}`;
}
