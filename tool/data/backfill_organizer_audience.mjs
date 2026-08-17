#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {createRequire} from "node:module";
import {fileURLToPath} from "node:url";
import {parseCommonArgs} from "../lib/cli_args.mjs";

const toolPath = fileURLToPath(import.meta.url);
const repoRoot = path.resolve(path.dirname(toolPath), "../..");
const requireFromFunctions = createRequire(
  path.join(repoRoot, "functions/package.json")
);
const options = {
  booleanFlags: ["--summary-only"],
  valueFlags: ["--organizer-id", "--identity-key"],
  allowPositionals: false,
  customFieldCase: "camel",
};

if (process.argv[1] && path.resolve(process.argv[1]) === toolPath) {
  await main();
}

export async function main(argv = process.argv.slice(2)) {
  const args = parseCommonArgs(argv, options);
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
  const plan = await buildOrganizerAudienceBackfillPlan(
    db,
    args.organizerId ?? null
  );
  printPlan(plan, args);
  if (!args.apply) {
    console.log("\nDry run only. Re-run with --apply and an identity key.");
    return;
  }
  const identityKey = args.identityKey ??
    process.env.ORGANIZER_CONTACT_IDENTITY_KEY;
  if (typeof identityKey !== "string" || identityKey.length < 32) {
    throw new Error(
      "--apply requires --identity-key or ORGANIZER_CONTACT_IDENTITY_KEY " +
      "with at least 32 characters."
    );
  }
  const projection = loadAudienceProjection();
  const result = await applyOrganizerAudienceBackfill({
    db,
    plan,
    identityKey,
    projection,
    timestamp: () => admin.firestore.Timestamp.now(),
  });
  console.log(JSON.stringify(result, null, 2));
}

export async function buildOrganizerAudienceBackfillPlan(
  firestore,
  organizerId = null
) {
  const organizers = new Map();
  const ensureOrganizer = (candidate) => {
    if (typeof candidate !== "string" || candidate.length === 0) return null;
    const current = organizers.get(candidate) ?? {
      organizerId: candidate,
      attendeeCount: 0,
      firstAttendeeId: null,
      lastAttendeeId: null,
    };
    organizers.set(candidate, current);
    return current;
  };
  if (organizerId) ensureOrganizer(organizerId);

  const collectionSnapshot = async (collectionName) => {
    let query = firestore.collection(collectionName);
    if (organizerId) query = query.where("organizerId", "==", organizerId);
    return query.get();
  };
  const [attendeeSnapshot, contactSnapshot, summarySnapshot] =
    await Promise.all([
      collectionSnapshot("eventAttendees"),
      collectionSnapshot("organizerContacts"),
      collectionSnapshot("organizerAudienceSummaries"),
    ]);

  let validAttendeeCount = 0;
  for (const doc of attendeeSnapshot.docs) {
    const attendee = doc.data();
    const current = ensureOrganizer(attendee.organizerId);
    if (!current) continue;
    current.attendeeCount += 1;
    current.firstAttendeeId ??= doc.id;
    current.lastAttendeeId = doc.id;
    validAttendeeCount += 1;
  }
  for (const doc of contactSnapshot.docs) {
    ensureOrganizer(doc.data().organizerId);
  }
  for (const doc of summarySnapshot.docs) {
    const summary = doc.data();
    if (summary.sourceCoverage !== "exact") {
      ensureOrganizer(summary.organizerId);
    }
  }
  return {
    attendeeCount: attendeeSnapshot.size,
    skippedInvalidOrganizerCount: attendeeSnapshot.size - validAttendeeCount,
    organizers: [...organizers.values()].sort((left, right) =>
      left.organizerId.localeCompare(right.organizerId)
    ),
  };
}

export async function applyOrganizerAudienceBackfill(params) {
  let projectedAttendees = 0;
  const completedOrganizers = [];
  for (const organizer of params.plan.organizers) {
    const snapshot = await params.db.collection("eventAttendees")
      .where("organizerId", "==", organizer.organizerId)
      .get();
    const docs = [...snapshot.docs].sort((left, right) =>
      left.id.localeCompare(right.id)
    );
    for (const doc of docs) {
      const attendee = doc.data();
      await params.projection.projectEventAttendeeToOrganizerAudience(
        doc.id,
        undefined,
        attendee,
        backfillReceiptId(doc.id, attendee),
        {
          firestore: () => params.db,
          timestamp: params.timestamp,
          identitySecret: () => params.identityKey,
        }
      );
      projectedAttendees += 1;
    }
    const coverageExact = await organizerAudienceCoverageIsExact(
      params.db,
      organizer.organizerId
    );
    await params.projection.rebuildOrganizerAudienceSummary(
      organizer.organizerId,
      coverageExact ? "exact" : "partial",
      {firestore: () => params.db, timestamp: params.timestamp}
    );
    if (coverageExact) completedOrganizers.push(organizer.organizerId);
  }
  return {
    projectedAttendees,
    completedOrganizerCount: completedOrganizers.length,
    completedOrganizers,
  };
}

export async function organizerAudienceCoverageIsExact(db, organizerId) {
  const snapshot = await db.collection("eventAttendees")
    .where("organizerId", "==", organizerId)
    .get();
  for (let index = 0; index < snapshot.docs.length; index += 250) {
    const attendees = snapshot.docs.slice(index, index + 250);
    const edgeSnaps = await db.getAll(...attendees.map((doc) =>
      db.collection("organizerContactEventEdges").doc(doc.id)
    ));
    for (let offset = 0; offset < attendees.length; offset += 1) {
      const attendee = attendees[offset].data();
      const edge = edgeSnaps[offset].data();
      if (!edge || edge.sourceUpdatedAt?.toMillis?.() !==
          attendee.updatedAt?.toMillis?.()) {
        return false;
      }
    }
  }
  return true;
}

export function backfillReceiptId(attendeeId, attendee) {
  const revision = attendee?.updatedAt?.toMillis?.() ?? "unknown";
  return `audience-backfill-v1:${attendeeId}:${revision}`;
}

function loadAudienceProjection() {
  try {
    return requireFromFunctions("./lib/organizers/organizerAudienceProjection.js");
  } catch (error) {
    throw new Error(
      "Could not load the built organizer audience projection. Run " +
      "`npm --prefix functions run build` first. " +
      `Original error: ${error.message}`
    );
  }
}

function resolveProjectId(args) {
  if (args.project) return args.project;
  if (args.env) {
    const project = readFirebaseRc().projects?.[args.env];
    if (!project) throw new Error(`Unknown Firebase alias: ${args.env}`);
    return project;
  }
  return process.env.GCLOUD_PROJECT ||
    process.env.GOOGLE_CLOUD_PROJECT || "catchdates-dev";
}

function isProductionTarget(args, projectId) {
  return args.env === "prod" || projectId === readFirebaseRc().projects?.prod;
}

function readFirebaseRc() {
  return JSON.parse(fs.readFileSync(path.join(repoRoot, ".firebaserc"), "utf8"));
}

function printPlan(plan, args) {
  if (args.json) {
    console.log(JSON.stringify(
      args.summaryOnly ? {
        attendeeCount: plan.attendeeCount,
        organizerCount: plan.organizers.length,
        skippedInvalidOrganizerCount: plan.skippedInvalidOrganizerCount,
      } : plan,
      null,
      2
    ));
    return;
  }
  console.log("Organizer audience backfill plan");
  console.log(`Attendees: ${plan.attendeeCount}`);
  console.log(`Organizers: ${plan.organizers.length}`);
  console.log(`Invalid organizer rows: ${plan.skippedInvalidOrganizerCount}`);
  if (!args.summaryOnly) {
    for (const organizer of plan.organizers) {
      console.log(`- ${organizer.organizerId}: ${organizer.attendeeCount}`);
    }
  }
}

function printHelp() {
  console.log(`Usage: node tool/data/backfill_organizer_audience.mjs [options]

Builds organizer contact/event/trait projections from canonical event attendees.
Dry run is the default. An organizer summary switches to exact coverage only
after every current attendee in that organizer has been projected. Discovery
also includes manual-contact and partial-summary organizers with zero attendees.

Options:
  --apply                   Write projections and exact summaries.
  --allow-prod              Required with --apply against prod.
  --organizer-id <id>       Restrict the run to one organizer.
  --identity-key <secret>   Stable 32+ character HMAC key. Prefer the env var.
  --summary-only            Omit per-organizer rows.
  --json                    Print JSON.
  --env <dev|staging|prod>  Resolve project id from .firebaserc.
  --project <id>            Firebase project id.
  --emulator                Use Firestore emulator at 127.0.0.1:8080.
  --emulator-host <host>    Use a custom Firestore emulator host.
  -h, --help                Show this help.
`);
}
