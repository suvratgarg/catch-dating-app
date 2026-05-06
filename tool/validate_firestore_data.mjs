#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {createRequire} from "node:module";
import {fileURLToPath} from "node:url";

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
  "users.joinedRunClubIds": 1000,
  "users.savedRunIds": 1000,
  "users.photoUrls": 12,
  "runClubs.memberUserIds": 5000,
  "runs.signedUpUserIds": 2000,
  "runs.attendedUserIds": 2000,
  "runs.waitlistUserIds": 2000,
  "matches.participantIds": 20,
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

const collections = await loadCollections(db, args.maxDocs);
validateAll(collections, report);

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
    help: false,
  };

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--json") parsed.json = true;
    else if (arg === "--fail-on-warning") parsed.failOnWarning = true;
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
  --json                         Emit machine-readable JSON.
  --fail-on-warning              Exit non-zero on warnings as well as errors.
`);
}

async function loadCollections(firestore, maxDocs) {
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

function validateAll(collections, currentReport) {
  const users = byId(collections.users);
  const publicProfiles = byId(collections.publicProfiles);
  const clubs = byId(collections.runClubs);
  const runs = byId(collections.runs);
  const matches = byId(collections.matches);

  for (const docs of Object.values(collections)) {
    for (const doc of docs) validateDocumentSize(doc, currentReport);
  }

  for (const doc of collections.users) validateUser(doc, clubs, currentReport);
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
    validateSwipe(doc, users, publicProfiles, runs, currentReport);
  }
  for (const doc of collections.matches) validateMatch(doc, users, currentReport);
  for (const doc of collections.messages) {
    validateMessage(doc, matches, currentReport);
  }
  for (const doc of collections.onboarding_drafts) {
    validateOnboardingDraft(doc, currentReport);
  }
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

function validateUser(doc, clubs, currentReport) {
  const data = doc.data;
  requireString(data, "name", doc, currentReport);
  requireTimestamp(data, "dateOfBirth", doc, currentReport);
  requireString(data, "gender", doc, currentReport);
  requireString(data, "phoneNumber", doc, currentReport);
  requireBool(data, "profileComplete", doc, currentReport);
  requireStringArray(data, "photoUrls", doc, currentReport);
  requireStringArray(data, "joinedRunClubIds", doc, currentReport);
  requireStringArray(data, "savedRunIds", doc, currentReport);
  requireStringArray(data, "interestedInGenders", doc, currentReport);
  checkArrayLimit("users.joinedRunClubIds", data.joinedRunClubIds, doc, currentReport);
  checkArrayLimit("users.savedRunIds", data.savedRunIds, doc, currentReport);
  checkArrayLimit("users.photoUrls", data.photoUrls, doc, currentReport);

  for (const clubId of data.joinedRunClubIds ?? []) {
    if (!clubs.has(clubId)) {
      issue(currentReport, "error", doc.path, "missing-joined-club",
        `joinedRunClubIds references missing runClubs/${clubId}.`);
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
  requireStringArray(data, "memberUserIds", doc, currentReport);
  requireInteger(data, "memberCount", doc, currentReport);
  requireNumber(data, "rating", doc, currentReport);
  requireInteger(data, "reviewCount", doc, currentReport);
  checkArrayLimit("runClubs.memberUserIds", data.memberUserIds, doc, currentReport);

  if (Array.isArray(data.memberUserIds) &&
      data.memberCount !== data.memberUserIds.length) {
    issue(currentReport, "error", doc.path, "member-count-mismatch",
      "memberCount does not match memberUserIds.length.");
  }
  if (data.hostUserId && !users.has(data.hostUserId)) {
    issue(currentReport, "warning", doc.path, "missing-host-user",
      `hostUserId references missing users/${data.hostUserId}.`);
  }
  if (Array.isArray(data.memberUserIds) &&
      !data.memberUserIds.includes(data.hostUserId)) {
    issue(currentReport, "error", doc.path, "host-not-member",
      "hostUserId is not present in memberUserIds.");
  }
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
  requireStringArray(data, "signedUpUserIds", doc, currentReport);
  requireStringArray(data, "attendedUserIds", doc, currentReport);
  requireStringArray(data, "waitlistUserIds", doc, currentReport);
  requireObject(data, "constraints", doc, currentReport);
  requireObject(data, "genderCounts", doc, currentReport);
  checkArrayLimit("runs.signedUpUserIds", data.signedUpUserIds, doc, currentReport);
  checkArrayLimit("runs.attendedUserIds", data.attendedUserIds, doc, currentReport);
  checkArrayLimit("runs.waitlistUserIds", data.waitlistUserIds, doc, currentReport);

  if (data.runClubId && !clubs.has(data.runClubId)) {
    issue(currentReport, "error", doc.path, "missing-run-club",
      `runClubId references missing runClubs/${data.runClubId}.`);
  }
  if (isTimestamp(data.startTime) && isTimestamp(data.endTime) &&
      data.endTime.toMillis() <= data.startTime.toMillis()) {
    issue(currentReport, "error", doc.path, "invalid-run-time",
      "endTime must be after startTime.");
  }
  if (Array.isArray(data.signedUpUserIds) &&
      data.signedUpUserIds.length > data.capacityLimit) {
    issue(currentReport, "error", doc.path, "over-capacity",
      "signedUpUserIds.length exceeds capacityLimit.");
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

function validateSwipe(doc, users, publicProfiles, runs, currentReport) {
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
  } else if (Array.isArray(run.data.attendedUserIds) &&
      (!run.data.attendedUserIds.includes(data.swiperId) ||
       !run.data.attendedUserIds.includes(data.targetId))) {
    issue(currentReport, "error", doc.path, "swipe-run-attendance-mismatch",
      "swiperId and targetId must both be in run.attendedUserIds.");
  }
}

function validateMatch(doc, users, currentReport) {
  const data = doc.data;
  requireString(data, "user1Id", doc, currentReport);
  requireString(data, "user2Id", doc, currentReport);
  requireStringArray(data, "participantIds", doc, currentReport);
  requireString(data, "runId", doc, currentReport);
  requireTimestamp(data, "createdAt", doc, currentReport);
  requireObject(data, "unreadCounts", doc, currentReport);
  requireString(data, "status", doc, currentReport);
  checkArrayLimit("matches.participantIds", data.participantIds, doc, currentReport);

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

function byId(docs) {
  return new Map(docs.map((doc) => [doc.id, doc]));
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
