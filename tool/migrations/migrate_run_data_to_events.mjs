#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {createRequire} from "node:module";
import {fileURLToPath, pathToFileURL} from "node:url";

const toolDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(toolDir, "../..");
const requireFromFunctions = createRequire(
  path.join(repoRoot, "functions/package.json")
);
const admin = requireFromFunctions("firebase-admin");

const BATCH_LIMIT = 450;
const HISTORICAL_MIGRATION_NOTICE =
  "Historical one-time migration kept for auditability. Do not run writes without an explicit migration owner/ticket and a reviewed dry run.";
const DEMO_FIELDS = [
  "synthetic",
  "seedPrefix",
  "scenario",
  "demoOps",
  "demoOpsId",
  "demoOpsCommand",
];

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
  if (args.apply && !args.ownerTicket) {
    throw new Error(
      "Refusing historical migration writes without --owner-ticket <id>."
    );
  }
  if (isProductionTarget(args, projectId) && args.apply && !args.confirmProd) {
    throw new Error("Refusing prod writes without --confirm-prod.");
  }

  admin.initializeApp({projectId});
  const db = admin.firestore();
  const plan = await buildMigrationPlan(db);
  plan.summary.ownerTicket = args.ownerTicket;

  if (args.json) {
    console.log(JSON.stringify(plan.summary, null, 2));
  } else {
    printSummary(plan.summary);
  }

  if (!args.apply) {
    console.log("\nDry run only. Re-run with --apply to write the migration.");
    return;
  }

  await applyMigrationPlan(db, plan);
  console.log("\nMigration writes applied.");
}

export async function buildMigrationPlan(db) {
  const [
    runClubs,
    runClubMemberships,
    runs,
    runParticipations,
    savedRuns,
    reviews,
    payments,
    matches,
    swipes,
    notificationItems,
  ] = await Promise.all([
    readCollection(db.collection("runClubs")),
    readCollection(db.collection("runClubMemberships")),
    readCollection(db.collection("runs")),
    readCollection(db.collection("runParticipations")),
    readCollection(db.collection("savedRuns")),
    readCollection(db.collection("reviews")),
    readCollection(db.collection("payments")),
    readCollection(db.collection("matches")),
    readCollectionGroup(db.collectionGroup("outgoing")),
    readCollectionGroup(db.collectionGroup("items")),
  ]);

  const eventClubByRunId = new Map();
  const eventAggregateByRunId = new Map();
  const activeMemberCountByClubId = new Map();
  const warnings = [];

  for (const doc of runs) {
    if (typeof doc.data.runClubId === "string") {
      eventClubByRunId.set(doc.id, doc.data.runClubId);
    }
  }

  const clubWrites = [];
  for (const doc of runClubs) {
    const data = doc.data;
    const hostUserId = stringOr(data.hostUserId, "");
    const hostName = stringOr(data.hostName, "Host");
    const hostAvatarUrl = nullableString(data.hostAvatarUrl);
    const club = {
      name: stringOr(data.name, "Untitled club"),
      description: stringOr(data.description, ""),
      location: stringOr(data.location, ""),
      area: stringOr(data.area, ""),
      hostUserId,
      hostName,
      hostAvatarUrl,
      ownerUserId: hostUserId,
      hostUserIds: hostUserId ? [hostUserId] : [],
      hostProfiles: hostUserId ? [{
        uid: hostUserId,
        displayName: hostName,
        avatarUrl: hostAvatarUrl,
        role: "owner",
      }] : [],
      createdAt: data.createdAt ?? admin.firestore.FieldValue.serverTimestamp(),
      imageUrl: nullableString(data.imageUrl),
      profileImageUrl: nullableString(data.profileImageUrl),
      tags: stringArray(data.tags),
      memberCount: 0,
      rating: numberOr(data.rating, 0),
      reviewCount: integerOr(data.reviewCount, 0),
      nextEventAt: data.nextRunAt ?? null,
      nextEventLabel: nullableString(data.nextRunLabel),
      instagramHandle: nullableString(data.instagramHandle),
      phoneNumber: nullableString(data.phoneNumber),
      email: nullableString(data.email),
      status: data.status === "archived" || data.archived === true ?
        "archived" :
        "active",
      archived: data.archived === true,
      archivedAt: data.archivedAt ?? null,
      archiveReason: nullableString(data.archiveReason),
      ...pickDemoFields(data),
    };
    clubWrites.push(setWrite(`clubs/${doc.id}`, club));
  }

  const membershipWrites = [];
  for (const doc of runClubMemberships) {
    const data = doc.data;
    if (!isNonEmptyString(data.clubId) || !isNonEmptyString(data.uid)) {
      warnings.push(`${doc.path} skipped: missing clubId or uid.`);
      continue;
    }
    const id = `${data.clubId}_${data.uid}`;
    if (doc.id !== id) {
      warnings.push(`${doc.path} id differs from deterministic ${id}.`);
    }
    const status = normalizeMembershipStatus(data.status);
    if (status === "active") {
      activeMemberCountByClubId.set(
        data.clubId,
        (activeMemberCountByClubId.get(data.clubId) ?? 0) + 1
      );
    }
    membershipWrites.push(setWrite(`clubMemberships/${id}`, {
      clubId: data.clubId,
      uid: data.uid,
      role: data.role === "host" ? "owner" : "member",
      status,
      pushNotificationsEnabled: data.pushNotificationsEnabled === true,
      joinedAt: data.joinedAt ?? admin.firestore.FieldValue.serverTimestamp(),
      leftAt: data.leftAt ?? null,
      deletedAt: data.deletedAt ?? null,
      ...pickDemoFields(data),
    }));
  }

  const hostClaimWrites = [];
  const claimedHosts = new Set();
  for (const doc of runClubs) {
    const data = doc.data;
    if (!isNonEmptyString(data.hostUserId) || claimedHosts.has(data.hostUserId)) {
      continue;
    }
    claimedHosts.add(data.hostUserId);
    hostClaimWrites.push(setWrite(`clubHostClaims/${data.hostUserId}`, {
      uid: data.hostUserId,
      clubId: doc.id,
      createdAt: data.createdAt ?? admin.firestore.FieldValue.serverTimestamp(),
    }));
  }

  const participationWrites = [];
  for (const doc of runParticipations) {
    const data = doc.data;
    if (!isNonEmptyString(data.runId) || !isNonEmptyString(data.uid)) {
      warnings.push(`${doc.path} skipped: missing runId or uid.`);
      continue;
    }
    const clubId = stringOr(data.runClubId, eventClubByRunId.get(data.runId));
    if (!clubId) {
      warnings.push(`${doc.path} skipped: missing runClubId.`);
      continue;
    }
    const status = normalizeParticipationStatus(data.status);
    const id = `${data.runId}_${data.uid}`;
    participationWrites.push(setWrite(`eventParticipations/${id}`, {
      eventId: data.runId,
      clubId,
      uid: data.uid,
      status,
      createdAt: data.createdAt ?? data.signedUpAt ??
        admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: data.updatedAt ?? data.createdAt ?? data.signedUpAt ??
        admin.firestore.FieldValue.serverTimestamp(),
      signedUpAt: data.signedUpAt ?? null,
      waitlistedAt: data.waitlistedAt ?? null,
      attendedAt: data.attendedAt ?? null,
      cancelledAt: data.cancelledAt ?? null,
      deletedAt: data.deletedAt ?? null,
      genderAtSignup: nullableString(data.genderAtSignup),
      cohortAtSignup: nullableString(data.cohortAtSignup),
      paymentId: nullableString(data.paymentId),
      ...pickDemoFields(data),
    }));
    updateEventAggregate(eventAggregateByRunId, data.runId, status, data);
  }

  const eventWrites = [];
  for (const doc of runs) {
    const data = doc.data;
    const aggregate = eventAggregateByRunId.get(doc.id) ?? emptyEventAggregate();
    eventWrites.push(setWrite(`events/${doc.id}`, {
      clubId: stringOr(data.runClubId, ""),
      startTime: data.startTime ?? admin.firestore.FieldValue.serverTimestamp(),
      endTime: data.endTime ?? admin.firestore.FieldValue.serverTimestamp(),
      meetingPoint: stringOr(data.meetingPoint, ""),
      startingPointLat: data.startingPointLat ?? null,
      startingPointLng: data.startingPointLng ?? null,
      locationDetails: nullableString(data.locationDetails),
      photoUrl: nullableString(data.photoUrl),
      eventFormat: {
        version: 1,
        activityKind: "socialRun",
        interactionModel: "pacePods",
        defaultPlaybookId: "social_run_light",
      },
      distanceKm: numberOr(data.distanceKm, 0),
      pace: normalizePace(data.pace),
      capacityLimit: integerOr(data.capacityLimit, 1),
      description: stringOr(data.description, ""),
      priceInPaise: integerOr(data.priceInPaise, 0),
      bookedCount: aggregate.bookedCount,
      checkedInCount: aggregate.checkedInCount,
      waitlistedCount: aggregate.waitlistedCount,
      status: data.status === "cancelled" ? "cancelled" : "active",
      cancelledAt: data.cancelledAt ?? null,
      cancellationReason: nullableString(data.cancellationReason),
      constraints: normalizeConstraints(data.constraints),
      genderCounts: aggregate.genderCounts,
      cohortCounts: {},
      waitlistedCohortCounts: {},
      ...pickDemoFields(data),
    }));
  }

  for (const write of clubWrites) {
    write.data.memberCount = activeMemberCountByClubId.get(idFromPath(write.path)) ?? 0;
  }

  const savedEventWrites = [];
  for (const doc of savedRuns) {
    const data = doc.data;
    if (!isNonEmptyString(data.uid) || !isNonEmptyString(data.runId)) {
      warnings.push(`${doc.path} skipped: missing uid or runId.`);
      continue;
    }
    const id = `${data.uid}_${data.runId}`;
    savedEventWrites.push(setWrite(`savedEvents/${id}`, {
      uid: data.uid,
      eventId: data.runId,
      savedAt: data.savedAt ?? admin.firestore.FieldValue.serverTimestamp(),
      ...pickDemoFields(data),
    }));
  }

  const reviewWrites = [];
  const reviewDeletes = [];
  for (const doc of reviews) {
    const data = doc.data;
    if (!isNonEmptyString(data.runId) || !isNonEmptyString(data.reviewerUserId)) {
      continue;
    }
    const clubId = stringOr(data.runClubId, eventClubByRunId.get(data.runId));
    if (!clubId) {
      warnings.push(`${doc.path} skipped: missing runClubId.`);
      continue;
    }
    const id = `${data.runId}~${data.reviewerUserId}`;
    reviewWrites.push(setWrite(`reviews/${id}`, {
      clubId,
      eventId: data.runId,
      reviewerUserId: data.reviewerUserId,
      reviewerName: stringOr(data.reviewerName, "Runner"),
      rating: integerOr(data.rating, 1),
      comment: stringOr(data.comment, ""),
      createdAt: data.createdAt ?? admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: data.updatedAt ?? null,
      ...pickDemoFields(data),
    }));
    if (doc.id !== id) reviewDeletes.push(deleteWrite(doc.path));
  }

  const paymentUpdates = [];
  for (const doc of payments) {
    if (isNonEmptyString(doc.data.runId)) {
      paymentUpdates.push(updateWrite(doc.path, {
        eventId: doc.data.runId,
        runId: admin.firestore.FieldValue.delete(),
      }));
    }
  }

  const matchUpdates = [];
  for (const doc of matches) {
    const data = doc.data;
    if (Array.isArray(data.runIds) || !Array.isArray(data.eventIds)) {
      matchUpdates.push(updateWrite(doc.path, {
        eventIds: Array.isArray(data.eventIds) ?
          stringArray(data.eventIds) :
          stringArray(data.runIds),
        runIds: admin.firestore.FieldValue.delete(),
      }));
    }
  }

  const swipeUpdates = [];
  for (const doc of swipes) {
    if (isNonEmptyString(doc.data.runId)) {
      swipeUpdates.push(updateWrite(doc.path, {
        eventId: doc.data.runId,
        runId: admin.firestore.FieldValue.delete(),
      }));
    }
  }

  const notificationUpdates = [];
  for (const doc of notificationItems) {
    const data = doc.data;
    const update = {};
    if (isNonEmptyString(data.runId)) {
      update.eventId = data.runId;
      update.runId = admin.firestore.FieldValue.delete();
    }
    if (isNonEmptyString(data.runClubId)) {
      update.clubId = data.runClubId;
      update.runClubId = admin.firestore.FieldValue.delete();
    }
    if (data.type === "runReminder") update.type = "eventReminder";
    if (data.type === "runSignup") update.type = "eventSignup";
    if (Object.keys(update).length > 0) {
      notificationUpdates.push(updateWrite(doc.path, update));
    }
  }

  const writes = [
    ...clubWrites,
    ...membershipWrites,
    ...hostClaimWrites,
    ...eventWrites,
    ...participationWrites,
    ...savedEventWrites,
    ...reviewWrites,
    ...reviewDeletes,
    ...paymentUpdates,
    ...matchUpdates,
    ...swipeUpdates,
    ...notificationUpdates,
  ];

  return {
    writes,
    summary: {
      source: {
        runClubs: runClubs.length,
        runClubMemberships: runClubMemberships.length,
        runs: runs.length,
        runParticipations: runParticipations.length,
        savedRuns: savedRuns.length,
        reviews: reviews.length,
        payments: payments.length,
        matches: matches.length,
        swipes: swipes.length,
        notificationItems: notificationItems.length,
      },
      targetWrites: {
        clubs: clubWrites.length,
        clubMemberships: membershipWrites.length,
        clubHostClaims: hostClaimWrites.length,
        events: eventWrites.length,
        eventParticipations: participationWrites.length,
        savedEvents: savedEventWrites.length,
        reviewsCreated: reviewWrites.length,
        legacyReviewsDeleted: reviewDeletes.length,
        paymentsUpdated: paymentUpdates.length,
        matchesUpdated: matchUpdates.length,
        swipesUpdated: swipeUpdates.length,
        notificationItemsUpdated: notificationUpdates.length,
      },
      totalWrites: writes.length,
      warnings,
    },
  };
}

export async function applyMigrationPlan(db, plan) {
  for (let i = 0; i < plan.writes.length; i += BATCH_LIMIT) {
    const batch = db.batch();
    for (const write of plan.writes.slice(i, i + BATCH_LIMIT)) {
      const ref = db.doc(write.path);
      if (write.type === "set") batch.set(ref, write.data);
      else if (write.type === "update") batch.update(ref, write.data);
      else if (write.type === "delete") batch.delete(ref);
    }
    await batch.commit();
  }
}

async function readCollection(ref) {
  const snap = await ref.get();
  return snap.docs.map(docFromSnapshot);
}

async function readCollectionGroup(ref) {
  const snap = await ref.get();
  return snap.docs.map(docFromSnapshot);
}

function docFromSnapshot(doc) {
  return {id: doc.id, path: doc.ref.path, data: doc.data()};
}

function setWrite(pathName, data) {
  return {type: "set", path: pathName, data};
}

function updateWrite(pathName, data) {
  return {type: "update", path: pathName, data};
}

function deleteWrite(pathName) {
  return {type: "delete", path: pathName};
}

function updateEventAggregate(aggregates, eventId, status, data) {
  const aggregate = eventAggregate(aggregates, eventId);
  if (status === "signedUp" || status === "attended") {
    aggregate.bookedCount += 1;
    if (isNonEmptyString(data.genderAtSignup)) {
      aggregate.genderCounts[data.genderAtSignup] =
        (aggregate.genderCounts[data.genderAtSignup] ?? 0) + 1;
    }
  }
  if (status === "attended") aggregate.checkedInCount += 1;
  if (status === "waitlisted") aggregate.waitlistedCount += 1;
}

function eventAggregate(aggregates, eventId) {
  if (!aggregates.has(eventId)) aggregates.set(eventId, emptyEventAggregate());
  return aggregates.get(eventId);
}

function emptyEventAggregate() {
  return {
    bookedCount: 0,
    checkedInCount: 0,
    waitlistedCount: 0,
    genderCounts: {},
  };
}

function pickDemoFields(data) {
  const result = {};
  for (const field of DEMO_FIELDS) {
    if (data[field] !== undefined) result[field] = data[field];
  }
  return result;
}

function normalizeMembershipStatus(value) {
  if (value === "left" || value === "deleted") return value;
  return "active";
}

function normalizeParticipationStatus(value) {
  if (["signedUp", "waitlisted", "attended", "cancelled", "deleted"].includes(value)) {
    return value;
  }
  return "signedUp";
}

function normalizePace(value) {
  if (["easy", "moderate", "fast", "competitive"].includes(value)) return value;
  return "easy";
}

function normalizeConstraints(value) {
  const data = value && typeof value === "object" ? value : {};
  return {
    minAge: integerOr(data.minAge, 0),
    maxAge: integerOr(data.maxAge, 99),
    maxMen: nullableInteger(data.maxMen),
    maxWomen: nullableInteger(data.maxWomen),
  };
}

function nullableInteger(value) {
  return Number.isInteger(value) ? value : null;
}

function integerOr(value, fallback) {
  return Number.isInteger(value) ? value : fallback;
}

function numberOr(value, fallback) {
  return typeof value === "number" && Number.isFinite(value) ? value : fallback;
}

function stringOr(value, fallback) {
  return isNonEmptyString(value) ? value : fallback;
}

function nullableString(value) {
  return typeof value === "string" && value.trim().length > 0 ? value : null;
}

function stringArray(value) {
  return Array.isArray(value) ? value.filter(isNonEmptyString) : [];
}

function isNonEmptyString(value) {
  return typeof value === "string" && value.trim().length > 0;
}

function idFromPath(pathName) {
  return pathName.split("/").at(-1);
}

function parseArgs(argv) {
  const parsed = {
    env: null,
    project: null,
    apply: false,
    confirmProd: false,
    ownerTicket: null,
    json: false,
    help: false,
  };

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--apply") parsed.apply = true;
    else if (arg === "--confirm-prod") parsed.confirmProd = true;
    else if (arg === "--owner-ticket") {
      parsed.ownerTicket = requireValue(argv, ++i, arg);
    }
    else if (arg === "--json") parsed.json = true;
    else if (arg === "--env") parsed.env = requireValue(argv, ++i, arg);
    else if (arg === "--project") parsed.project = requireValue(argv, ++i, arg);
    else throw new Error(`Unknown argument: ${arg}`);
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
  const firebaserc = JSON.parse(
    fs.readFileSync(path.join(repoRoot, ".firebaserc"), "utf8")
  );
  if (parsed.env) {
    const project = firebaserc.projects?.[parsed.env];
    if (!project) throw new Error(`No Firebase project alias found for ${parsed.env}.`);
    return project;
  }
  return firebaserc.projects?.dev ?? "catchdates-dev";
}

function isProductionTarget(parsed, projectId) {
  const firebaserc = JSON.parse(
    fs.readFileSync(path.join(repoRoot, ".firebaserc"), "utf8")
  );
  return parsed.env === "prod" || projectId === firebaserc.projects?.prod;
}

function printHelp() {
  console.log(`Usage: node tool/migrations/migrate_run_data_to_events.mjs --env <env> [options]

${HISTORICAL_MIGRATION_NOTICE}

Copies legacy runClubs/runs data into clubs/events and updates old runId fields.

Options:
  --apply          Apply writes. Default is dry-run.
  --confirm-prod   Required with --apply for the prod alias/project.
  --owner-ticket <id>
                   Required with --apply for historical auditability.
  --json           Print JSON summary.
  --env <env>      Resolve project id from .firebaserc.
  --project <id>   Explicit Firebase project id.
  -h, --help       Show this help.
`);
}

function printSummary(summary) {
  console.log("Legacy run data migration plan");
  if (summary.ownerTicket) console.log(`Owner ticket: ${summary.ownerTicket}`);
  console.log(`Source: ${JSON.stringify(summary.source)}`);
  console.log(`Target writes: ${JSON.stringify(summary.targetWrites)}`);
  console.log(`Total writes: ${summary.totalWrites}`);
  if (summary.warnings.length > 0) {
    console.log("\nWarnings:");
    for (const warning of summary.warnings.slice(0, 50)) {
      console.log(`- ${warning}`);
    }
    if (summary.warnings.length > 50) {
      console.log(`... ${summary.warnings.length - 50} more warnings`);
    }
  }
}

function isMain() {
  return process.argv[1] &&
    import.meta.url === pathToFileURL(process.argv[1]).href;
}
