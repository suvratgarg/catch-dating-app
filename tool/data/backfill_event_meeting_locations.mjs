#!/usr/bin/env node
import {isDeepStrictEqual} from "node:util";
import {fileURLToPath} from "node:url";
import {
  applyFirestoreEmulatorHost,
  assertProdWriteAllowed,
  resolveFirebaseProjectId,
} from "../lib/firebase_project.mjs";
import {parseCommonArgs} from "../lib/cli_args.mjs";
import {createFunctionsRequire} from "../lib/repo_paths.mjs";

const requireFromFunctions = createFunctionsRequire();
const admin = requireFromFunctions("firebase-admin");

if (isMain()) await main();

export async function main(argv = process.argv.slice(2)) {
  const args = parseArgs(argv);
  if (args.help) {
    printHelp();
    return;
  }

  const projectId = resolveFirebaseProjectId({
    env: args.env,
    project: args.project,
  });
  assertProdWriteAllowed({
    env: args.env,
    projectId,
    apply: args.apply,
    allowProd: args.allowProd,
    action: "backfill event meeting locations in",
  });
  applyFirestoreEmulatorHost(args.emulatorHost);

  const app = admin.initializeApp({projectId}, "event-meeting-location-backfill");
  try {
    const db = app.firestore();
    const plan = await buildEventMeetingLocationBackfillPlan(db);
    const output = args.summary_only ? compactSummary(plan.summary) : plan.summary;
    if (args.json) {
      console.log(JSON.stringify(output, null, 2));
    } else {
      printSummary(output, {summaryOnly: args.summary_only});
    }

    if (!args.apply) {
      console.log("\nDry run only. Re-run with --apply to write repairs.");
      return;
    }
    await applyEventMeetingLocationBackfillPlan(db, plan);
    console.log(`\nApplied ${plan.repairs.length} event location repair(s).`);
  } finally {
    await app.delete();
  }
}

export async function buildEventMeetingLocationBackfillPlan(firestore) {
  const eventsSnap = await firestore.collection("events").get();
  const repairs = [];
  const blockers = [];
  const warnings = [];
  let validStructuredLocations = 0;
  let legacyLocationsUsed = 0;

  for (const doc of eventsSnap.docs) {
    const result = canonicalEventMeetingLocation(doc.data(), {
      path: doc.ref.path,
      eventId: doc.id,
    });
    warnings.push(...result.warnings);
    if (result.blocker) {
      blockers.push(result.blocker);
      continue;
    }
    if (result.structuredPairUsed) validStructuredLocations += 1;
    if (result.legacyDataUsed) legacyLocationsUsed += 1;
    const patch = changedPatch(doc.data(), result.expected);
    if (Object.keys(patch).length > 0) {
      repairs.push({
        path: doc.ref.path,
        eventId: doc.id,
        source: result.source,
        patch,
      });
    }
  }

  const summary = {
    eventsScanned: eventsSnap.size,
    validStructuredLocations,
    legacyLocationsUsed,
    repairsNeeded: repairs.length,
    blockerCount: blockers.length,
    warningCount: warnings.length,
    warnings,
    blockers,
    repairs,
  };
  return {repairs, blockers, warnings, summary};
}

export function canonicalEventMeetingLocation(
  event,
  {path = "events/unknown", eventId = "unknown"} = {}
) {
  const reasons = [];
  const warnings = [];
  const structured = isPlainObject(event?.meetingLocation) ?
    event.meetingLocation :
    null;
  if (event?.meetingLocation != null && !structured) {
    reasons.push("meetingLocation must be an object");
  }

  const structuredName = boundedRequiredString(
    structured?.name,
    240,
    "meetingLocation.name",
    reasons,
    {required: false}
  );
  const legacyName = boundedRequiredString(
    event?.meetingPoint,
    240,
    "meetingPoint",
    reasons,
    {required: false}
  );
  const name = structuredName ?? legacyName;
  if (!name) reasons.push("a nonblank meeting location name is required");

  const structuredPair = coordinatePair(
    structured?.latitude,
    structured?.longitude
  );
  const legacyPair = coordinatePair(
    event?.startingPointLat,
    event?.startingPointLng
  );
  const pair = structuredPair ?? legacyPair;
  if (!pair) reasons.push("a complete in-range coordinate pair is required");
  if (structured && !structuredPair && legacyPair) {
    warnings.push(`${path}: invalid structured coordinates; used legacy pair.`);
  }
  if (structuredPair && legacyPair && !isDeepStrictEqual(structuredPair, legacyPair)) {
    warnings.push(`${path}: structured coordinates override drifted legacy mirrors.`);
  }

  const address = boundedOptionalString(
    structured?.address,
    500,
    "meetingLocation.address",
    reasons
  );
  const placeId = boundedOptionalString(
    structured?.placeId,
    256,
    "meetingLocation.placeId",
    reasons
  );
  const structuredNotes = boundedOptionalString(
    structured?.notes,
    1000,
    "meetingLocation.notes",
    reasons
  );
  const legacyNotes = boundedOptionalString(
    event?.locationDetails,
    1000,
    "locationDetails",
    reasons
  );
  const notes = structuredNotes ?? legacyNotes;

  if (reasons.length > 0) {
    return {
      blocker: {path, eventId, reasons: [...new Set(reasons)]},
      warnings,
      expected: null,
      source: null,
      structuredPairUsed: false,
      legacyDataUsed: false,
    };
  }

  const structuredPairUsed = structuredPair != null;
  const legacyDataUsed = !structuredName || !structuredPairUsed ||
    (structuredNotes == null && legacyNotes != null);
  const source = structuredName && structuredPairUsed ?
    (legacyDataUsed ? "mixed" : "structured") :
    structured ? "mixed" : "legacy";
  const meetingLocation = {
    name,
    address,
    placeId,
    latitude: pair.latitude,
    longitude: pair.longitude,
    notes,
  };
  return {
    blocker: null,
    warnings,
    source,
    structuredPairUsed,
    legacyDataUsed,
    expected: {
      meetingPoint: name,
      meetingLocation,
      startingPointLat: pair.latitude,
      startingPointLng: pair.longitude,
      locationDetails: notes,
    },
  };
}

export async function applyEventMeetingLocationBackfillPlan(firestore, plan) {
  if (plan.blockers.length > 0) {
    throw new Error(
      `Refusing to apply with ${plan.blockers.length} unresolved blocker(s).`
    );
  }
  for (let index = 0; index < plan.repairs.length; index += 450) {
    const batch = firestore.batch();
    for (const repair of plan.repairs.slice(index, index + 450)) {
      batch.update(firestore.doc(repair.path), repair.patch);
    }
    await batch.commit();
  }
}

function changedPatch(source, expected) {
  const patch = {};
  for (const [key, value] of Object.entries(expected)) {
    if (!isDeepStrictEqual(source?.[key], value)) patch[key] = value;
  }
  return patch;
}

function coordinatePair(latitude, longitude) {
  return validCoordinate(latitude, -90, 90) &&
    validCoordinate(longitude, -180, 180) ?
    {latitude, longitude} :
    null;
}

function validCoordinate(value, minimum, maximum) {
  return typeof value === "number" &&
    Number.isFinite(value) &&
    value >= minimum &&
    value <= maximum;
}

function boundedRequiredString(
  value,
  maximum,
  field,
  reasons,
  {required = true} = {}
) {
  if (value == null) {
    if (required) reasons.push(`${field} is required`);
    return null;
  }
  if (typeof value !== "string") {
    reasons.push(`${field} must be a string`);
    return null;
  }
  const normalized = value.trim();
  if (!normalized) {
    if (required) reasons.push(`${field} must not be blank`);
    return null;
  }
  if (normalized.length > maximum) {
    reasons.push(`${field} exceeds ${maximum} characters`);
    return null;
  }
  return normalized;
}

function boundedOptionalString(value, maximum, field, reasons) {
  if (value == null) return null;
  if (typeof value !== "string") {
    reasons.push(`${field} must be a string or null`);
    return null;
  }
  const normalized = value.trim();
  if (!normalized) return null;
  if (normalized.length > maximum) {
    reasons.push(`${field} exceeds ${maximum} characters`);
    return null;
  }
  return normalized;
}

function isPlainObject(value) {
  return value != null && typeof value === "object" && !Array.isArray(value);
}

function compactSummary(summary) {
  return {
    eventsScanned: summary.eventsScanned,
    validStructuredLocations: summary.validStructuredLocations,
    legacyLocationsUsed: summary.legacyLocationsUsed,
    repairsNeeded: summary.repairsNeeded,
    blockerCount: summary.blockerCount,
    warningCount: summary.warningCount,
    warnings: summary.warnings,
    blockers: summary.blockers,
  };
}

function printSummary(summary, {summaryOnly = false} = {}) {
  console.log("Event meeting-location backfill plan");
  console.log(`Events scanned: ${summary.eventsScanned}`);
  console.log(`Valid structured locations: ${summary.validStructuredLocations}`);
  console.log(`Legacy locations used: ${summary.legacyLocationsUsed}`);
  console.log(`Repairs needed: ${summary.repairsNeeded}`);
  console.log(`Blockers: ${summary.blockerCount}`);
  console.log(`Warnings: ${summary.warningCount}`);
  if (!summaryOnly) {
    for (const repair of summary.repairs) {
      console.log(`- repair ${repair.path} (${repair.source})`);
    }
  }
  for (const warning of summary.warnings) console.log(`- warning ${warning}`);
  for (const blocker of summary.blockers) {
    console.log(`- BLOCKED ${blocker.path}: ${blocker.reasons.join("; ")}`);
  }
}

function parseArgs(argv) {
  return parseCommonArgs(argv, {booleanFlags: ["--summary-only"]});
}

function printHelp() {
  console.log(`Usage: node tool/data/backfill_event_meeting_locations.mjs [options]

Audits events for an exact structured meeting location, promotes deterministic
legacy values, and synchronizes compatibility mirrors. Dry-run by default.

Options:
  --apply                 Write repairs. Default is dry-run.
  --allow-prod            Required with --apply against prod.
  --json                  Print JSON output.
  --summary-only          Omit per-event repair details.
  --env <dev|staging|prod> Resolve project id from .firebaserc.
  --project <id>          Firebase project id override.
  --emulator              Use Firestore emulator at 127.0.0.1:8080.
  --emulator-host <host>  Use a custom Firestore emulator host.
  -h, --help              Show this help.`);
}

function isMain() {
  return process.argv[1] && fileURLToPath(import.meta.url) === process.argv[1];
}
