#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {createRequire} from "node:module";
import {fileURLToPath} from "node:url";

const toolPath = fileURLToPath(import.meta.url);
const repoRoot = path.resolve(path.dirname(toolPath), "../..");
const requireFromFunctions = createRequire(
  path.join(repoRoot, "functions/package.json")
);
const supplyCollections = ["organizers", "clubs"];

if (process.argv[1] && path.resolve(process.argv[1]) === toolPath) {
  await main();
}

export async function main(argv = process.argv.slice(2)) {
  const args = parseArgs(argv);
  if (args.help) return printHelp();
  const projectId = resolveProjectId(args);
  if (args.apply && isProductionTarget(args, projectId) && !args.allowProd) {
    throw new Error(
      "Refusing to backfill prod without --allow-prod. Run a dry run first, " +
      "then rerun with --apply --allow-prod."
    );
  }
  if (args.emulatorHost) {
    process.env.FIRESTORE_EMULATOR_HOST = args.emulatorHost;
  }
  const admin = requireFromFunctions("firebase-admin");
  if (admin.apps.length === 0) admin.initializeApp({projectId});
  const db = admin.firestore();
  const plan = await buildOrganizerSupplyCapabilityRepairPlan(db);
  console.log(JSON.stringify(plan.summary, null, 2));
  if (plan.summary.invalid > 0) {
    throw new Error(
      "Refusing to apply while stored capability sets exceed canonical " +
      "ownership authority."
    );
  }
  if (!args.apply) {
    console.log("\nDry run only. Re-run with --apply to write repairs.");
    return;
  }
  await applyOrganizerSupplyCapabilityRepairPlan(db, plan);
  console.log("\nApplied organizer supply capability repairs.");
}

export async function buildOrganizerSupplyCapabilityRepairPlan(firestore) {
  const repairs = [];
  const invalid = [];
  const scannedByCollection = {};
  let alreadyCurrent = 0;
  for (const collectionName of supplyCollections) {
    const snapshot = await firestore.collection(collectionName).get();
    scannedByCollection[collectionName] = snapshot.size;
    for (const doc of snapshot.docs) {
      const result = supplyCapabilityPatchForEntity(doc.data());
      if (result.status === "current") {
        alreadyCurrent += 1;
      } else if (result.status === "invalid") {
        invalid.push({path: doc.ref.path, reason: result.reason});
      } else {
        repairs.push({path: doc.ref.path, patch: result.patch});
      }
    }
  }
  const externalSnapshot = await firestore.collection("externalEvents").get();
  for (const doc of externalSnapshot.docs) {
    const data = doc.data();
    if (
      data.organizerCapabilities === undefined ||
      !Array.isArray(data.review?.blockerResolutions)
    ) {
      invalid.push({
        path: doc.ref.path,
        reason:
          "existing external event needs manual capability and blocker " +
          "provenance review",
      });
    }
  }
  return {
    repairs,
    invalid,
    summary: {
      scannedByCollection,
      externalEventsScanned: externalSnapshot.size,
      repairsNeeded: repairs.length,
      alreadyCurrent,
      invalid: invalid.length,
      invalidDocuments: invalid,
    },
  };
}

export function supplyCapabilityPatchForEntity(entity) {
  const expected = organizerSupplyCapabilitiesForEntity(entity);
  if (entity?.supplyCapabilities === undefined) {
    return {status: "repair", patch: {supplyCapabilities: expected}};
  }
  if (stableJson(entity.supplyCapabilities) === stableJson(expected)) {
    return {status: "current"};
  }
  return {
    status: "invalid",
    reason: "stored capabilities do not match ownership and claim authority",
  };
}

export function organizerSupplyCapabilitiesForEntity(entity) {
  const ownershipState = stringValue(entity?.ownership?.state);
  const claimState = stringValue(entity?.claim?.state);
  const managed = ["userCreated", "claimed", "transferred"].includes(
    ownershipState
  ) || ["claimed", "verified"].includes(claimState);
  if (managed) {
    return {
      mode: "claimed_managed",
      bookable: true,
      paymentsEnabled: true,
      waitlistEnabled: true,
      hostContactEnabled: true,
      claimable: false,
      reviewPolicy: "attended_event_only",
    };
  }
  return {
    mode: "unclaimed_read_only",
    bookable: false,
    paymentsEnabled: false,
    waitlistEnabled: false,
    hostContactEnabled: false,
    claimable: claimState === "unclaimed",
    reviewPolicy: "after_event_end",
  };
}

export async function applyOrganizerSupplyCapabilityRepairPlan(
  firestore,
  plan
) {
  if (plan.invalid.length > 0) {
    throw new Error("Cannot apply a plan with invalid documents.");
  }
  for (let index = 0; index < plan.repairs.length; index += 450) {
    const batch = firestore.batch();
    for (const repair of plan.repairs.slice(index, index + 450)) {
      batch.update(firestore.doc(repair.path), repair.patch);
    }
    await batch.commit();
  }
}

function stableJson(value) {
  if (Array.isArray(value)) return `[${value.map(stableJson).join(",")}]`;
  if (value && typeof value === "object") {
    return `{${Object.keys(value).sort().map((key) =>
      `${JSON.stringify(key)}:${stableJson(value[key])}`
    ).join(",")}}`;
  }
  return JSON.stringify(value);
}

function stringValue(value) {
  return typeof value === "string" ? value : "";
}

function parseArgs(argv) {
  const parsed = {
    env: null,
    project: null,
    emulatorHost: null,
    apply: false,
    allowProd: false,
    help: false,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--apply") parsed.apply = true;
    else if (arg === "--allow-prod") parsed.allowProd = true;
    else if (arg === "--emulator") {
      parsed.emulatorHost = "127.0.0.1:8080";
    } else if (arg === "--emulator-host") {
      parsed.emulatorHost = requireValue(argv, ++index, arg);
    } else if (arg === "--env") {
      parsed.env = requireValue(argv, ++index, arg);
    } else if (arg === "--project") {
      parsed.project = requireValue(argv, ++index, arg);
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
    const project = readFirebaseRc().projects?.[parsed.env];
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
  return parsed.env === "prod" ||
    projectId === readFirebaseRc().projects?.prod;
}

function readFirebaseRc() {
  return JSON.parse(
    fs.readFileSync(path.join(repoRoot, ".firebaserc"), "utf8")
  );
}

function printHelp() {
  console.log(`Usage: node tool/data/backfill_organizer_supply_capabilities.mjs [options]

Backfills the organizer-level member-affordance ceiling on organizers and the
clubs compatibility projection. Existing external events are audit-only: any
missing capability or blocker provenance requires manual review. Dry-run is
the default.

Options:
  --apply                  Write organizer and club repairs.
  --allow-prod             Required with --apply against prod.
  --env <dev|staging|prod> Resolve project id from .firebaserc.
  --project <id>           Firebase project id.
  --emulator               Use Firestore emulator at 127.0.0.1:8080.
  --emulator-host <host>   Use a custom Firestore emulator host.
  -h, --help               Show this help.
`);
}
