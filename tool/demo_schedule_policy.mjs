import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const toolDir = path.dirname(fileURLToPath(import.meta.url));
const businessRules = JSON.parse(
  fs.readFileSync(path.join(toolDir, "business_rules.json"), "utf8")
);

const MINUTE_MS = 60 * 1000;
const USER_SCHEDULE_STATUSES = new Set(["signedUp", "waitlisted", "attended"]);
const RUN_CLUB_LOCK_COLLECTION = "runClubScheduleLocks";
const USER_RUN_LOCK_COLLECTION = "userRunScheduleLocks";

export const RUN_MAX_DURATION_MINUTES =
  businessRules.runScheduling.maxDurationMinutes;
export const RUN_SCHEDULE_LOCK_SLOT_MINUTES =
  businessRules.runScheduling.scheduleLockSlotMinutes;

export function scheduleComplianceIssues({
  runs,
  participations = [],
  runClubScheduleLocks = [],
  userRunScheduleLocks = [],
  checkLocks = false,
}) {
  const issues = [];
  const runWindows = new Map();
  for (const run of runs) {
    try {
      const window = runWindow(run);
      runWindows.set(window.runId, window);
      validateRunWindow(window, issues);
    } catch (error) {
      issues.push({
        code: "invalid-run-schedule-shape",
        path: run.path ?? `runs/${run.id ?? "unknown"}`,
        message: error.message,
      });
    }
  }

  const activeRunsByClub = groupBy(
    [...runWindows.values()].filter((run) => run.status !== "cancelled"),
    (run) => run.runClubId
  );
  for (const clubRuns of activeRunsByClub.values()) {
    forEachOverlappingPair(clubRuns, (first, second) => {
      issues.push({
        code: "run-club-schedule-overlap",
        path: `runs/${second.runId}`,
        message:
          `Run club ${second.runClubId} has overlapping runs ` +
          `${first.runId} and ${second.runId}.`,
      });
    });
  }

  const scheduledParticipations = [];
  for (const participation of participations) {
    const data = participation.data ?? participation.doc ?? participation;
    if (!USER_SCHEDULE_STATUSES.has(data.status)) continue;
    const run = runWindows.get(data.runId);
    if (!run) {
      issues.push({
        code: "missing-participation-run",
        path: participation.path ?? `runParticipations/${participation.id ?? "unknown"}`,
        message: `Participation references missing runs/${data.runId}.`,
      });
      continue;
    }
    if (run.status === "cancelled") {
      issues.push({
        code: "scheduled-participation-cancelled-run",
        path: participation.path ?? `runParticipations/${participation.id ?? "unknown"}`,
        message: `Scheduled participation references cancelled runs/${run.runId}.`,
      });
      continue;
    }
    scheduledParticipations.push({
      uid: data.uid,
      runId: data.runId,
      runClubId: data.runClubId ?? run.runClubId,
      startTimeMillis: run.startTimeMillis,
      endTimeMillis: run.endTimeMillis,
      path: participation.path ?? `runParticipations/${participation.id ?? `${data.runId}_${data.uid}`}`,
    });
  }

  const participationsByUser = groupBy(scheduledParticipations, (item) => item.uid);
  for (const userParticipations of participationsByUser.values()) {
    forEachOverlappingPair(userParticipations, (first, second) => {
      issues.push({
        code: "user-run-schedule-overlap",
        path: second.path,
        message:
          `User ${second.uid} has overlapping run participations ` +
          `${first.runId} and ${second.runId}.`,
      });
    });
  }

  if (checkLocks) {
    issues.push(...scheduleLockIssues({
      runWindows,
      scheduledParticipations,
      runClubScheduleLocks,
      userRunScheduleLocks,
    }));
  }

  return issues;
}

export function assertScheduleCompliance(params) {
  const issues = scheduleComplianceIssues(params);
  if (issues.length > 0) {
    throw new Error(
      "Demo schedule data violates run schedule policy:\n" +
      issues.map((issue) => `- ${issue.code}: ${issue.message}`).join("\n")
    );
  }
}

export function buildRunClubScheduleLockDocs({run}) {
  const window = runWindow(run);
  if (window.status === "cancelled") return [];
  validateRunWindow(window);
  return scheduleSlots(window).map((slot) => ({
    path: `${RUN_CLUB_LOCK_COLLECTION}/${window.runClubId}_${slot}`,
    data: {
      ...demoMarkerFor(window.data),
      ownerType: "runClub",
      ownerId: window.runClubId,
      slot,
      runId: window.runId,
      runClubId: window.runClubId,
      startTimeMillis: window.startTimeMillis,
      endTimeMillis: window.endTimeMillis,
    },
  }));
}

export function buildUserRunScheduleLockDocs({run, participation}) {
  const data = participation.data ?? participation.doc ?? participation;
  if (!USER_SCHEDULE_STATUSES.has(data.status)) return [];
  const window = runWindow(run);
  if (window.status === "cancelled") return [];
  validateRunWindow(window);
  return scheduleSlots(window).map((slot) => ({
    path: `${USER_RUN_LOCK_COLLECTION}/${data.uid}_${slot}`,
    data: {
      ...demoMarkerFor(data),
      ownerType: "user",
      ownerId: data.uid,
      slot,
      runId: window.runId,
      runClubId: data.runClubId ?? window.runClubId,
      uid: data.uid,
      startTimeMillis: window.startTimeMillis,
      endTimeMillis: window.endTimeMillis,
    },
  }));
}

export function buildScheduleLockDocs({runs, participations}) {
  const runById = new Map(runs.map((run) => [run.id, run]));
  const docs = [];
  for (const run of runs) {
    docs.push(...buildRunClubScheduleLockDocs({run}));
  }
  for (const participation of participations) {
    const data = participation.data ?? participation.doc ?? participation;
    const run = runById.get(data.runId);
    if (run) docs.push(...buildUserRunScheduleLockDocs({run, participation}));
  }
  return assertUniqueScheduleLockDocs(docs);
}

export async function assertNoUserRunScheduleConflictInFirestore({
  db,
  uid,
  run,
}) {
  const next = runWindow(run);
  const participationSnap = await db.collection("runParticipations")
    .where("uid", "==", uid)
    .get();
  for (const doc of participationSnap.docs) {
    const data = doc.data();
    if (!USER_SCHEDULE_STATUSES.has(data.status) || data.runId === next.runId) {
      continue;
    }
    const runSnap = await db.collection("runs").doc(data.runId).get();
    if (!runSnap.exists) continue;
    const existing = runWindow({
      id: runSnap.id,
      path: runSnap.ref?.path ?? `runs/${runSnap.id}`,
      data: runSnap.data(),
    });
    if (existing.status !== "cancelled" && intervalsOverlap(
      next.startTimeMillis,
      next.endTimeMillis,
      existing.startTimeMillis,
      existing.endTimeMillis
    )) {
      throw new Error(
        `User ${uid} already has a scheduled participation for ` +
        `${existing.runId} during runs/${next.runId}.`
      );
    }
  }
}

function scheduleLockIssues({
  runWindows,
  scheduledParticipations,
  runClubScheduleLocks,
  userRunScheduleLocks,
}) {
  const issues = [];
  const expected = new Map();
  for (const run of runWindows.values()) {
    if (run.status === "cancelled") continue;
    for (const slot of scheduleSlots(run)) {
      expected.set(`${RUN_CLUB_LOCK_COLLECTION}/${run.runClubId}_${slot}`, {
        ownerType: "runClub",
        ownerId: run.runClubId,
        slot,
        runId: run.runId,
      });
    }
  }
  for (const participation of scheduledParticipations) {
    for (const slot of scheduleSlots(participation)) {
      expected.set(`${USER_RUN_LOCK_COLLECTION}/${participation.uid}_${slot}`, {
        ownerType: "user",
        ownerId: participation.uid,
        slot,
        runId: participation.runId,
      });
    }
  }

  const actual = new Map([
    ...runClubScheduleLocks.map((doc) => [doc.path, doc]),
    ...userRunScheduleLocks.map((doc) => [doc.path, doc]),
  ]);
  for (const [pathValue, expectedData] of expected.entries()) {
    const doc = actual.get(pathValue);
    if (!doc) {
      issues.push({
        code: "missing-schedule-lock",
        path: pathValue,
        message: `${pathValue} is missing for runs/${expectedData.runId}.`,
      });
      continue;
    }
    for (const field of ["ownerType", "ownerId", "slot", "runId"]) {
      if (doc.data?.[field] !== expectedData[field]) {
        issues.push({
          code: "schedule-lock-field-mismatch",
          path: pathValue,
          message: `${field} does not match the expected schedule lock value.`,
        });
      }
    }
  }
  for (const pathValue of actual.keys()) {
    if (!expected.has(pathValue)) {
      issues.push({
        code: "stale-schedule-lock",
        path: pathValue,
        message: `${pathValue} does not correspond to an active run schedule.`,
      });
    }
  }
  return issues;
}

function runWindow(run) {
  const data = run.data ?? run.doc ?? run;
  const runId = run.id ?? data.id;
  const runClubId = run.clubId ?? data.runClubId;
  if (typeof runId !== "string") throw new Error("run id must be a string.");
  if (typeof runClubId !== "string") {
    throw new Error(`runs/${runId} runClubId must be a string.`);
  }
  return {
    runId,
    runClubId,
    status: data.status ?? "active",
    data,
    path: run.path ?? `runs/${runId}`,
    startTimeMillis: timestampMillis(data.startTime),
    endTimeMillis: timestampMillis(data.endTime),
  };
}

function validateRunWindow(window, issues = null) {
  const add = (code, message) => {
    const issue = {code, path: window.path, message};
    if (issues) issues.push(issue);
    else throw new Error(message);
  };
  if (window.endTimeMillis <= window.startTimeMillis) {
    add("invalid-run-time", `${window.path} endTime must be after startTime.`);
  }
  const durationMinutes = (window.endTimeMillis - window.startTimeMillis) / MINUTE_MS;
  if (durationMinutes > RUN_MAX_DURATION_MINUTES) {
    add(
      "run-duration-too-long",
      `${window.path} lasts ${durationMinutes} minutes; max is ` +
        `${RUN_MAX_DURATION_MINUTES}.`
    );
  }
}

function scheduleSlots({startTimeMillis, endTimeMillis}) {
  const slotMs = RUN_SCHEDULE_LOCK_SLOT_MINUTES * MINUTE_MS;
  const firstSlot = Math.floor(startTimeMillis / slotMs);
  const lastSlot = Math.floor((endTimeMillis - 1) / slotMs);
  const slots = [];
  for (let slot = firstSlot; slot <= lastSlot; slot += 1) slots.push(slot);
  return slots;
}

function timestampMillis(value) {
  if (value instanceof Date) return value.getTime();
  if (typeof value === "number") return value;
  if (value && typeof value.toMillis === "function") return value.toMillis();
  throw new Error("startTime and endTime must be timestamps, dates, or millis.");
}

function forEachOverlappingPair(items, callback) {
  const sorted = [...items].sort((a, b) =>
    a.startTimeMillis - b.startTimeMillis || a.endTimeMillis - b.endTimeMillis
  );
  for (let i = 0; i < sorted.length; i += 1) {
    for (let j = i + 1; j < sorted.length; j += 1) {
      if (sorted[j].startTimeMillis >= sorted[i].endTimeMillis) break;
      if (intervalsOverlap(
        sorted[i].startTimeMillis,
        sorted[i].endTimeMillis,
        sorted[j].startTimeMillis,
        sorted[j].endTimeMillis
      )) {
        callback(sorted[i], sorted[j]);
      }
    }
  }
}

function intervalsOverlap(startA, endA, startB, endB) {
  return startA < endB && startB < endA;
}

function groupBy(values, keyFn) {
  const result = new Map();
  for (const value of values) {
    const key = keyFn(value);
    if (!result.has(key)) result.set(key, []);
    result.get(key).push(value);
  }
  return result;
}

function demoMarkerFor(data) {
  const marker = {};
  for (const key of [
    "synthetic",
    "seedPrefix",
    "scenario",
    "demoOps",
    "demoOpsCommand",
    "demoOpsId",
  ]) {
    if (data?.[key] !== undefined) marker[key] = data[key];
  }
  return marker;
}

function assertUniqueScheduleLockDocs(docs) {
  const byPath = new Map();
  for (const doc of docs) {
    const existing = byPath.get(doc.path);
    if (existing && existing.data.runId !== doc.data.runId) {
      throw new Error(
        `Schedule lock collision at ${doc.path}: ` +
        `${existing.data.runId} conflicts with ${doc.data.runId}.`
      );
    }
    byPath.set(doc.path, doc);
  }
  return [...byPath.values()];
}
