#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {createRequire} from "node:module";
import {fileURLToPath} from "node:url";
import {
  RUN_MAX_DURATION_MINUTES,
  scheduleComplianceIssues,
} from "./demo_schedule_policy.mjs";

const toolDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(toolDir, "..");
const requireFromFunctions = createRequire(
  path.join(repoRoot, "functions/package.json")
);
const admin = requireFromFunctions("firebase-admin");

const DEFAULT_MAX_DOCS = 5000;
const WARN_DOC_BYTES = 768 * 1024;
const ERROR_DOC_BYTES = 950 * 1024;

const ARRAY_LIMITS = {
  "users.photoUrls": 12,
  "matches.participantIds": 20,
  "matches.runIds": 100,
};

const args = parseArgs(process.argv.slice(2));
if (args.help) {
  printHelp();
  process.exit(0);
}

const projectId = resolveProjectId(args);
if (args.emulatorHost) {
  process.env.FIRESTORE_EMULATOR_HOST = args.emulatorHost;
}

admin.initializeApp({projectId});
const db = admin.firestore();
const report = createReport({projectId, emulatorHost: args.emulatorHost});

const collections = await loadCollections(db, args.maxDocs, {
  includeScheduleLocks: args.checkScheduleLocks,
});
validateAll(collections, report, {checkScheduleLocks: args.checkScheduleLocks});

if (args.json) {
  console.log(JSON.stringify(report, null, 2));
} else {
  printReport(report);
}

if (report.summary.errors > 0 || (args.failOnWarning && report.summary.warnings > 0)) {
  process.exit(1);
}

function parseArgs(argv) {
  const parsed = {
    env: null,
    project: null,
    emulatorHost: null,
    maxDocs: DEFAULT_MAX_DOCS,
    json: false,
    failOnWarning: false,
    checkScheduleLocks: false,
    help: false,
  };

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--json") parsed.json = true;
    else if (arg === "--fail-on-warning") parsed.failOnWarning = true;
    else if (arg === "--check-schedule-locks") parsed.checkScheduleLocks = true;
    else if (arg === "--emulator") parsed.emulatorHost = "127.0.0.1:8080";
    else if (arg === "--emulator-host") parsed.emulatorHost = requireValue(argv, ++i, arg);
    else if (arg === "--env") parsed.env = requireValue(argv, ++i, arg);
    else if (arg === "--project") parsed.project = requireValue(argv, ++i, arg);
    else if (arg === "--max-docs") {
      parsed.maxDocs = Number.parseInt(requireValue(argv, ++i, arg), 10);
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }

  if (!Number.isInteger(parsed.maxDocs) || parsed.maxDocs < 1) {
    throw new Error("--max-docs must be a positive integer.");
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
    const firebaserc = JSON.parse(
      fs.readFileSync(path.join(repoRoot, ".firebaserc"), "utf8")
    );
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

function printHelp() {
  console.log(`
Read-only Firestore data validator.

Usage:
  node tool/validate_firestore_data.mjs --env dev
  node tool/validate_firestore_data.mjs --env staging --json
  node tool/validate_firestore_data.mjs --project catchdates-dev
  node tool/validate_firestore_data.mjs --env dev --emulator

Options:
  --env <dev|staging|prod>       Resolve project id from .firebaserc.
  --project <firebase-project>   Explicit Firebase/GCP project id.
  --emulator                     Use FIRESTORE_EMULATOR_HOST=127.0.0.1:8080.
  --emulator-host <host:port>    Use a custom Firestore emulator host.
  --max-docs <n>                 Per-collection cap, default ${DEFAULT_MAX_DOCS}.
  --check-schedule-locks         Also verify server schedule lock documents.
  --json                         Emit machine-readable JSON.
  --fail-on-warning              Exit non-zero on warnings as well as errors.
`);
}

async function loadCollections(firestore, maxDocs, {includeScheduleLocks = false} = {}) {
  const topLevel = [
    "users",
    "publicProfiles",
    "runClubs",
    "runClubMemberships",
    "runs",
    "runParticipations",
    "savedRuns",
    "reviews",
    "matches",
    "onboarding_drafts",
  ];
  const result = {};
  for (const collectionName of topLevel) {
    result[collectionName] = await readQuery(
      firestore.collection(collectionName),
      maxDocs
    );
  }
  result.runClubScheduleLocks = includeScheduleLocks ?
    await readQuery(firestore.collection("runClubScheduleLocks"), maxDocs) :
    [];
  result.userRunScheduleLocks = includeScheduleLocks ?
    await readQuery(firestore.collection("userRunScheduleLocks"), maxDocs) :
    [];
  result.swipes = await readQuery(
    firestore.collectionGroup("outgoing"),
    maxDocs
  );
  result.messages = await readQuery(
    firestore.collectionGroup("messages"),
    maxDocs
  );
  return result;
}

async function readQuery(query, maxDocs) {
  const snap = await query.limit(maxDocs).get();
  return snap.docs.map((doc) => ({
    id: doc.id,
    path: doc.ref.path,
    data: doc.data(),
    bytes: estimateBytes(doc.data()),
  }));
}

function createReport({projectId, emulatorHost}) {
  return {
    projectId,
    emulatorHost: emulatorHost ?? null,
    generatedAt: new Date().toISOString(),
    summary: {
      scannedDocuments: 0,
      errors: 0,
      warnings: 0,
      largestDocuments: [],
    },
    issues: [],
  };
}

function validateAll(collections, currentReport, {checkScheduleLocks = false} = {}) {
  const users = byId(collections.users);
  const publicProfiles = byId(collections.publicProfiles);
  const clubs = byId(collections.runClubs);
  const runs = byId(collections.runs);
  const runParticipations = byId(collections.runParticipations);
  const matches = byId(collections.matches);

  for (const docs of Object.values(collections)) {
    for (const doc of docs) validateDocumentSize(doc, currentReport);
  }

  for (const doc of collections.users) validateUser(doc, currentReport);
  validateSyntheticPublicProfileIdentities(
    collections.publicProfiles,
    currentReport
  );
  for (const doc of collections.runClubs) {
    validateRunClub(doc, users, currentReport);
  }
  for (const doc of collections.runClubMemberships) {
    validateRunClubMembership(doc, users, clubs, currentReport);
  }
  for (const doc of collections.runs) validateRun(doc, clubs, currentReport);
  for (const doc of collections.runParticipations) {
    validateRunParticipation(doc, users, runs, currentReport);
  }
  for (const doc of collections.savedRuns) {
    validateSavedRun(doc, users, runs, currentReport);
  }
  for (const doc of collections.reviews) {
    validateReview(doc, users, clubs, runs, currentReport);
  }
  for (const doc of collections.swipes) {
    validateSwipe(doc, users, publicProfiles, runs, runParticipations,
      currentReport);
  }
  for (const doc of collections.matches) validateMatch(doc, users, currentReport);
  for (const doc of collections.messages) {
    validateMessage(doc, matches, currentReport);
  }
  for (const doc of collections.onboarding_drafts) {
    validateOnboardingDraft(doc, currentReport);
  }
  validateRunClubMemberCountAggregates(
    collections.runClubs,
    collections.runClubMemberships,
    currentReport
  );
  validateRunAggregateCounts(
    collections.runs,
    collections.runParticipations,
    currentReport
  );
  validateSchedulePolicy(collections, currentReport, {checkScheduleLocks});
}

function validateDocumentSize(doc, currentReport) {
  currentReport.summary.scannedDocuments += 1;
  currentReport.summary.largestDocuments.push({
    path: doc.path,
    bytes: doc.bytes,
  });
  currentReport.summary.largestDocuments.sort((a, b) => b.bytes - a.bytes);
  currentReport.summary.largestDocuments =
    currentReport.summary.largestDocuments.slice(0, 20);

  if (doc.bytes >= ERROR_DOC_BYTES) {
    issue(currentReport, "error", doc.path, "doc-size-error",
      `Document is near Firestore's 1 MiB limit: ${doc.bytes} bytes.`);
  } else if (doc.bytes >= WARN_DOC_BYTES) {
    issue(currentReport, "warning", doc.path, "doc-size-warning",
      `Document is large enough to monitor: ${doc.bytes} bytes.`);
  }
}

function validateUser(doc, currentReport) {
  const data = doc.data;
  requireString(data, "name", doc, currentReport);
  requireTimestamp(data, "dateOfBirth", doc, currentReport);
  requireString(data, "gender", doc, currentReport);
  requireString(data, "phoneNumber", doc, currentReport);
  requireBool(data, "profileComplete", doc, currentReport);
  requireStringArray(data, "photoUrls", doc, currentReport);
  if (data.photoThumbnailUrls !== undefined) {
    requireStringArray(data, "photoThumbnailUrls", doc, currentReport);
  }
  requireStringArray(data, "interestedInGenders", doc, currentReport);
  checkArrayLimit("users.photoUrls", data.photoUrls, doc, currentReport);
}

function validateSyntheticPublicProfileIdentities(publicProfiles, currentReport) {
  const seen = new Map();

  for (const doc of publicProfiles) {
    const data = doc.data;
    if (!isSyntheticPublicProfile(doc)) continue;

    const name = normalizedPublicName(data.name);
    const firstPhoto = Array.isArray(data.photoUrls) ? data.photoUrls[0] : null;
    if (!name || typeof firstPhoto !== "string" || firstPhoto.length === 0) {
      continue;
    }

    const key = `${name}|${firstPhoto}`;
    const firstPath = seen.get(key);
    if (firstPath) {
      issue(currentReport, "warning", doc.path,
        "duplicate-synthetic-public-identity",
        `Synthetic public profile has the same visible name and primary photo as ${firstPath}.`);
    } else {
      seen.set(key, doc.path);
    }
  }
}

function validateRunClub(doc, users, currentReport) {
  const data = doc.data;
  requireString(data, "name", doc, currentReport);
  requireString(data, "description", doc, currentReport);
  requireString(data, "location", doc, currentReport);
  requireString(data, "area", doc, currentReport);
  requireString(data, "hostUserId", doc, currentReport);
  requireString(data, "hostName", doc, currentReport);
  requireTimestamp(data, "createdAt", doc, currentReport);
  requireStringArray(data, "tags", doc, currentReport);
  requireInteger(data, "memberCount", doc, currentReport);
  requireNumber(data, "rating", doc, currentReport);
  requireInteger(data, "reviewCount", doc, currentReport);

  if (Number.isInteger(data.memberCount) && data.memberCount < 0) {
    issue(currentReport, "error", doc.path, "negative-member-count",
      "memberCount cannot be negative.");
  }
  if (data.hostUserId && !users.has(data.hostUserId)) {
    issue(currentReport, "warning", doc.path, "missing-host-user",
      `hostUserId references missing users/${data.hostUserId}.`);
  }
}

function isSyntheticPublicProfile(doc) {
  return doc.data.synthetic === true ||
    typeof doc.data.seedPrefix === "string" ||
    doc.id.startsWith("demo_");
}

function validateRunClubMembership(doc, users, clubs, currentReport) {
  const data = doc.data;
  requireString(data, "clubId", doc, currentReport);
  requireString(data, "uid", doc, currentReport);
  requireString(data, "role", doc, currentReport);
  requireString(data, "status", doc, currentReport);
  requireTimestamp(data, "joinedAt", doc, currentReport);

  if (!["host", "member"].includes(data.role)) {
    issue(currentReport, "error", doc.path, "invalid-membership-role",
      "role must be host or member.");
  }
  if (!["active", "left", "deleted"].includes(data.status)) {
    issue(currentReport, "error", doc.path, "invalid-membership-status",
      "status must be active, left, or deleted.");
  }
  if (data.clubId && data.uid && doc.id !== `${data.clubId}_${data.uid}`) {
    issue(currentReport, "error", doc.path, "membership-id-mismatch",
      "document id must be {clubId}_{uid}.");
  }
  if (data.clubId && !clubs.has(data.clubId)) {
    issue(currentReport, "warning", doc.path, "missing-membership-club",
      `clubId references missing runClubs/${data.clubId}.`);
  }
  if (data.uid && !users.has(data.uid)) {
    issue(currentReport, "warning", doc.path, "missing-membership-user",
      `uid references missing users/${data.uid}.`);
  }
}

function validateRun(doc, clubs, currentReport) {
  const data = doc.data;
  requireString(data, "runClubId", doc, currentReport);
  requireTimestamp(data, "startTime", doc, currentReport);
  requireTimestamp(data, "endTime", doc, currentReport);
  requireString(data, "meetingPoint", doc, currentReport);
  requireNumber(data, "distanceKm", doc, currentReport);
  requireString(data, "pace", doc, currentReport);
  requireInteger(data, "capacityLimit", doc, currentReport);
  requireString(data, "description", doc, currentReport);
  requireInteger(data, "priceInPaise", doc, currentReport);
  requireInteger(data, "bookedCount", doc, currentReport);
  requireInteger(data, "checkedInCount", doc, currentReport);
  requireInteger(data, "waitlistedCount", doc, currentReport);
  requireObject(data, "constraints", doc, currentReport);
  requireObject(data, "genderCounts", doc, currentReport);

  if (data.runClubId && !clubs.has(data.runClubId)) {
    issue(currentReport, "error", doc.path, "missing-run-club",
      `runClubId references missing runClubs/${data.runClubId}.`);
  }
  if (isTimestamp(data.startTime) && isTimestamp(data.endTime) &&
      data.endTime.toMillis() <= data.startTime.toMillis()) {
    issue(currentReport, "error", doc.path, "invalid-run-time",
      "endTime must be after startTime.");
  }
  if (isTimestamp(data.startTime) && isTimestamp(data.endTime)) {
    const durationMinutes =
      (data.endTime.toMillis() - data.startTime.toMillis()) / (60 * 1000);
    if (durationMinutes > RUN_MAX_DURATION_MINUTES) {
      issue(currentReport, "error", doc.path, "run-duration-too-long",
        `Run duration is ${durationMinutes} minutes, max ${RUN_MAX_DURATION_MINUTES}.`);
    }
  }
  if (Number.isInteger(data.bookedCount) &&
      data.bookedCount > data.capacityLimit) {
    issue(currentReport, "error", doc.path, "over-capacity",
      "bookedCount exceeds capacityLimit.");
  }
  for (const field of ["bookedCount", "checkedInCount", "waitlistedCount"]) {
    if (Number.isInteger(data[field]) && data[field] < 0) {
      issue(currentReport, "error", doc.path, "negative-run-count",
        `${field} cannot be negative.`);
    }
  }
  if ((data.startingPointLat == null) !== (data.startingPointLng == null)) {
    issue(currentReport, "error", doc.path, "partial-coordinates",
      "startingPointLat and startingPointLng must be set together.");
  }
}

function validateRunParticipation(doc, users, runs, currentReport) {
  const data = doc.data;
  requireString(data, "runId", doc, currentReport);
  requireString(data, "runClubId", doc, currentReport);
  requireString(data, "uid", doc, currentReport);
  requireString(data, "status", doc, currentReport);
  requireTimestamp(data, "createdAt", doc, currentReport);
  requireTimestamp(data, "updatedAt", doc, currentReport);

  if (!["signedUp", "waitlisted", "attended", "cancelled", "deleted"]
    .includes(data.status)) {
    issue(currentReport, "error", doc.path, "invalid-participation-status",
      "status must be signedUp, waitlisted, attended, cancelled, or deleted.");
  }
  if (data.runId && data.uid && doc.id !== `${data.runId}_${data.uid}`) {
    issue(currentReport, "error", doc.path, "participation-id-mismatch",
      "document id must be {runId}_{uid}.");
  }
  const run = runs.get(data.runId);
  if (!run) {
    issue(currentReport, "warning", doc.path, "missing-participation-run",
      `runId references missing runs/${data.runId}.`);
  } else if (run.data.runClubId !== data.runClubId) {
    issue(currentReport, "error", doc.path, "participation-club-mismatch",
      "runClubId does not match the parent run.");
  }
  if (data.uid && !users.has(data.uid)) {
    issue(currentReport, "warning", doc.path, "missing-participation-user",
      `uid references missing users/${data.uid}.`);
  }
}

function validateSavedRun(doc, users, runs, currentReport) {
  const data = doc.data;
  requireString(data, "uid", doc, currentReport);
  requireString(data, "runId", doc, currentReport);
  requireTimestamp(data, "savedAt", doc, currentReport);

  if (data.uid && data.runId && doc.id !== `${data.uid}_${data.runId}`) {
    issue(currentReport, "error", doc.path, "saved-run-id-mismatch",
      "document id must be {uid}_{runId}.");
  }
  if (data.uid && !users.has(data.uid)) {
    issue(currentReport, "warning", doc.path, "missing-saved-run-user",
      `uid references missing users/${data.uid}.`);
  }
  if (data.runId && !runs.has(data.runId)) {
    issue(currentReport, "warning", doc.path, "missing-saved-run",
      `runId references missing runs/${data.runId}.`);
  }
}

function validateReview(doc, users, clubs, runs, currentReport) {
  const data = doc.data;
  requireString(data, "runClubId", doc, currentReport);
  requireString(data, "reviewerUserId", doc, currentReport);
  requireString(data, "reviewerName", doc, currentReport);
  requireInteger(data, "rating", doc, currentReport);
  requireString(data, "comment", doc, currentReport);
  requireTimestamp(data, "createdAt", doc, currentReport);

  if (data.rating < 1 || data.rating > 5) {
    issue(currentReport, "error", doc.path, "invalid-rating",
      "rating must be between 1 and 5.");
  }
  if (data.runClubId && !clubs.has(data.runClubId)) {
    issue(currentReport, "error", doc.path, "missing-review-club",
      `runClubId references missing runClubs/${data.runClubId}.`);
  }
  if (!data.runId) {
    issue(currentReport, "warning", doc.path, "legacy-review-id",
      "Review has no runId; new reviews must be run-scoped.");
  } else {
    const expectedId = `${data.runId}~${data.reviewerUserId}`;
    if (doc.id !== expectedId) {
      issue(currentReport, "error", doc.path, "review-id-mismatch",
        `Expected deterministic review id ${expectedId}.`);
    }
    const run = runs.get(data.runId);
    if (!run) {
      issue(currentReport, "error", doc.path, "missing-review-run",
        `runId references missing runs/${data.runId}.`);
    } else if (run.data.runClubId !== data.runClubId) {
      issue(currentReport, "error", doc.path, "review-run-club-mismatch",
        "Review runId belongs to a different runClubId.");
    }
  }
  const reviewer = users.get(data.reviewerUserId);
  if (reviewer && reviewer.data.name !== data.reviewerName) {
    issue(currentReport, "warning", doc.path, "reviewer-name-drift",
      "reviewerName differs from the current users/{uid}.name.");
  }
}

function validateSwipe(doc, users, publicProfiles, runs, runParticipations,
  currentReport) {
  const data = doc.data;
  const pathMatch = /^swipes\/([^/]+)\/outgoing\/([^/]+)$/.exec(doc.path);
  requireString(data, "swiperId", doc, currentReport);
  requireString(data, "targetId", doc, currentReport);
  requireString(data, "runId", doc, currentReport);
  requireString(data, "direction", doc, currentReport);
  requireTimestamp(data, "createdAt", doc, currentReport);

  if (!["like", "pass"].includes(data.direction)) {
    issue(currentReport, "error", doc.path, "invalid-swipe-direction",
      "direction must be like or pass.");
  }
  if (pathMatch &&
      (pathMatch[1] !== data.swiperId || pathMatch[2] !== data.targetId)) {
    issue(currentReport, "error", doc.path, "swipe-path-data-mismatch",
      "swipe path user IDs do not match swiperId/targetId.");
  }
  if (data.swiperId && !users.has(data.swiperId)) {
    issue(currentReport, "warning", doc.path, "missing-swiper-user",
      `swiperId references missing users/${data.swiperId}.`);
  }
  if (data.targetId && !publicProfiles.has(data.targetId)) {
    issue(currentReport, "warning", doc.path, "missing-target-profile",
      `targetId references missing publicProfiles/${data.targetId}.`);
  }
  const run = runs.get(data.runId);
  if (!run) {
    issue(currentReport, "error", doc.path, "missing-swipe-run",
      `runId references missing runs/${data.runId}.`);
  } else if (!hasAttendedRun(runParticipations, data.runId, data.swiperId) ||
      !hasAttendedRun(runParticipations, data.runId, data.targetId)) {
    issue(currentReport, "error", doc.path, "swipe-run-attendance-mismatch",
      "swiperId and targetId must both have attended runParticipations for the swipe run.");
  }
}

function hasAttendedRun(runParticipations, runId, uid) {
  if (!runId || !uid) return false;
  const participation = runParticipations.get(`${runId}_${uid}`);
  return participation?.data?.status === "attended";
}

function validateMatch(doc, users, currentReport) {
  const data = doc.data;
  requireString(data, "user1Id", doc, currentReport);
  requireString(data, "user2Id", doc, currentReport);
  requireStringArray(data, "participantIds", doc, currentReport);
  if (Array.isArray(data.runIds)) {
    requireStringArray(data, "runIds", doc, currentReport);
  } else {
    requireString(data, "runId", doc, currentReport);
  }
  requireTimestamp(data, "createdAt", doc, currentReport);
  requireObject(data, "unreadCounts", doc, currentReport);
  requireString(data, "status", doc, currentReport);
  checkArrayLimit("matches.participantIds", data.participantIds, doc, currentReport);
  checkArrayLimit("matches.runIds", data.runIds, doc, currentReport);

  for (const uid of [data.user1Id, data.user2Id]) {
    if (uid && !users.has(uid)) {
      issue(currentReport, "warning", doc.path, "missing-match-user",
        `${uid} is not present in users.`);
    }
  }
  if (Array.isArray(data.participantIds) &&
      (!data.participantIds.includes(data.user1Id) ||
       !data.participantIds.includes(data.user2Id))) {
    issue(currentReport, "error", doc.path, "participant-id-mismatch",
      "participantIds must include user1Id and user2Id.");
  }
}

function validateMessage(doc, matches, currentReport) {
  const data = doc.data;
  const pathMatch = /^matches\/([^/]+)\/messages\/([^/]+)$/.exec(doc.path);
  const legacyPathMatch = /^chats\/([^/]+)\/messages\/([^/]+)$/.exec(doc.path);
  requireString(data, "senderId", doc, currentReport);
  requireTimestamp(data, "sentAt", doc, currentReport);
  if (typeof data.text !== "string" && typeof data.imageUrl !== "string") {
    issue(currentReport, "error", doc.path, "message-empty-content",
      "message must contain text or imageUrl.");
  }
  if (legacyPathMatch) {
    issue(currentReport, "warning", doc.path, "legacy-chat-message-path",
      "message still lives under chats/{matchId}/messages; migrate it to matches/{matchId}/messages.");
  }
  if (!pathMatch) return;
  const match = matches.get(pathMatch[1]);
  if (!match) {
    issue(currentReport, "warning", doc.path, "missing-message-match",
      `Message belongs to missing matches/${pathMatch[1]}.`);
  } else if (Array.isArray(match.data.participantIds) &&
      !match.data.participantIds.includes(data.senderId)) {
    issue(currentReport, "error", doc.path, "message-sender-not-participant",
      "senderId is not a participant in the parent match.");
  }
}

function validateOnboardingDraft(doc, currentReport) {
  requireInteger(doc.data, "step", doc, currentReport);
}

function validateRunClubMemberCountAggregates(
  runClubs,
  runClubMemberships,
  currentReport
) {
  const activeCounts = new Map();
  for (const doc of runClubMemberships) {
    const data = doc.data;
    if (data.status !== "active" || typeof data.clubId !== "string") continue;
    activeCounts.set(data.clubId, (activeCounts.get(data.clubId) ?? 0) + 1);
  }

  for (const doc of runClubs) {
    const expected = activeCounts.get(doc.id) ?? 0;
    if (doc.data.memberCount !== expected) {
      issue(currentReport, "error", doc.path, "member-count-drift",
        `memberCount is ${doc.data.memberCount}, but active ` +
        `runClubMemberships count is ${expected}.`);
    }
  }
}

function validateRunAggregateCounts(runs, runParticipations, currentReport) {
  const aggregates = new Map();
  for (const doc of runParticipations) {
    const data = doc.data;
    if (typeof data.runId !== "string") continue;
    const aggregate = runAggregate(aggregates, data.runId);
    if (data.status === "signedUp" || data.status === "attended") {
      aggregate.bookedCount += 1;
      if (typeof data.genderAtSignup === "string") {
        aggregate.genderCounts[data.genderAtSignup] =
          (aggregate.genderCounts[data.genderAtSignup] ?? 0) + 1;
      }
    }
    if (data.status === "attended") aggregate.checkedInCount += 1;
    if (data.status === "waitlisted") aggregate.waitlistedCount += 1;
  }

  for (const doc of runs) {
    const expected = runAggregate(aggregates, doc.id);
    for (const field of ["bookedCount", "checkedInCount", "waitlistedCount"]) {
      if (doc.data[field] !== expected[field]) {
        issue(currentReport, "error", doc.path, "run-count-drift",
          `${field} is ${doc.data[field]}, but runParticipations imply ` +
          `${expected[field]}.`);
      }
    }
    if (JSON.stringify(normalizeObject(doc.data.genderCounts ?? {})) !==
        JSON.stringify(normalizeObject(expected.genderCounts))) {
      issue(currentReport, "error", doc.path, "run-gender-count-drift",
        "genderCounts does not match signedUp/attended runParticipations.");
    }
  }
}

function validateSchedulePolicy(collections, currentReport, {checkScheduleLocks}) {
  const issues = scheduleComplianceIssues({
    runs: collections.runs,
    participations: collections.runParticipations,
    runClubScheduleLocks: collections.runClubScheduleLocks,
    userRunScheduleLocks: collections.userRunScheduleLocks,
    checkLocks: checkScheduleLocks,
  });
  for (const found of issues) {
    issue(currentReport, "error", found.path, found.code, found.message);
  }
}

function runAggregate(aggregates, runId) {
  if (!aggregates.has(runId)) {
    aggregates.set(runId, {
      bookedCount: 0,
      checkedInCount: 0,
      waitlistedCount: 0,
      genderCounts: {},
    });
  }
  return aggregates.get(runId);
}

function normalizeObject(value) {
  return Object.fromEntries(Object.entries(value).sort());
}

function byId(docs) {
  return new Map(docs.map((doc) => [doc.id, doc]));
}

function normalizedPublicName(value) {
  return typeof value === "string" ? value.trim().toLowerCase() : "";
}

function requireString(data, field, doc, currentReport) {
  if (typeof data[field] !== "string") {
    typeIssue(field, "string", doc, currentReport);
  }
}

function requireBool(data, field, doc, currentReport) {
  if (typeof data[field] !== "boolean") {
    typeIssue(field, "boolean", doc, currentReport);
  }
}

function requireNumber(data, field, doc, currentReport) {
  if (typeof data[field] !== "number" || Number.isNaN(data[field])) {
    typeIssue(field, "number", doc, currentReport);
  }
}

function requireInteger(data, field, doc, currentReport) {
  if (!Number.isInteger(data[field])) {
    typeIssue(field, "integer", doc, currentReport);
  }
}

function requireObject(data, field, doc, currentReport) {
  if (typeof data[field] !== "object" ||
      data[field] === null ||
      Array.isArray(data[field])) {
    typeIssue(field, "object", doc, currentReport);
  }
}

function requireTimestamp(data, field, doc, currentReport) {
  if (!isTimestamp(data[field])) {
    typeIssue(field, "Firestore Timestamp", doc, currentReport);
  }
}

function requireStringArray(data, field, doc, currentReport) {
  if (!Array.isArray(data[field]) ||
      !data[field].every((value) => typeof value === "string")) {
    typeIssue(field, "string[]", doc, currentReport);
  }
}

function typeIssue(field, expected, doc, currentReport) {
  issue(currentReport, "error", doc.path, "field-type",
    `${field} must be ${expected}.`);
}

function checkArrayLimit(key, value, doc, currentReport) {
  if (!Array.isArray(value)) return;
  const max = ARRAY_LIMITS[key];
  if (max && value.length > max) {
    issue(currentReport, "error", doc.path, "array-length",
      `${key} has ${value.length} items, max ${max}.`);
  }
}

function isTimestamp(value) {
  return value &&
    typeof value.toMillis === "function" &&
    typeof value.toDate === "function";
}

function estimateBytes(value) {
  return Buffer.byteLength(JSON.stringify(toJsonSafe(value)), "utf8");
}

function toJsonSafe(value) {
  if (isTimestamp(value)) return {__timestampMillis: value.toMillis()};
  if (Array.isArray(value)) return value.map(toJsonSafe);
  if (value && typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value).map(([key, item]) => [key, toJsonSafe(item)])
    );
  }
  return value;
}

function issue(currentReport, severity, pathValue, code, message) {
  currentReport.issues.push({severity, path: pathValue, code, message});
  if (severity === "error") currentReport.summary.errors += 1;
  else currentReport.summary.warnings += 1;
}

function printReport(currentReport) {
  console.log("Firestore data validation report");
  console.log(`Project: ${currentReport.projectId}`);
  if (currentReport.emulatorHost) {
    console.log(`Emulator: ${currentReport.emulatorHost}`);
  }
  console.log(`Scanned docs: ${currentReport.summary.scannedDocuments}`);
  console.log(`Errors: ${currentReport.summary.errors}`);
  console.log(`Warnings: ${currentReport.summary.warnings}`);

  if (currentReport.issues.length > 0) {
    console.log("\nIssues:");
    for (const found of currentReport.issues.slice(0, 200)) {
      console.log(
        `- [${found.severity}] ${found.path} ${found.code}: ${found.message}`
      );
    }
    if (currentReport.issues.length > 200) {
      console.log(`... ${currentReport.issues.length - 200} more issues`);
    }
  }

  if (currentReport.summary.largestDocuments.length > 0) {
    console.log("\nLargest documents:");
    for (const doc of currentReport.summary.largestDocuments.slice(0, 10)) {
      console.log(`- ${doc.path}: ${doc.bytes} bytes`);
    }
  }
}
