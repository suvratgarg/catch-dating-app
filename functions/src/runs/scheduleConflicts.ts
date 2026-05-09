/* eslint-disable require-jsdoc */
import {HttpsError} from "firebase-functions/v2/https";
import {RunDoc} from "../shared/firestore";
import {
  RUN_MAX_DURATION_MINUTES,
  RUN_SCHEDULE_LOCK_SLOT_MINUTES,
} from "../shared/businessRules";

const MINUTE_MS = 60 * 1000;
const RUN_CLUB_LOCK_COLLECTION = "runClubScheduleLocks";
const USER_LOCK_COLLECTION = "userRunScheduleLocks";
const USER_SCHEDULE_STATUSES = ["signedUp", "waitlisted", "attended"];

type LockOwner = "runClub" | "user";

interface ScheduleWindow {
  startTimeMillis: number;
  endTimeMillis: number;
}

interface ClaimRunClubScheduleParams extends ScheduleWindow {
  runClubId: string;
  runId: string;
}

interface ReplaceRunClubScheduleParams extends ClaimRunClubScheduleParams {
  previousStartTimeMillis: number;
  previousEndTimeMillis: number;
}

interface ClaimUserScheduleParams extends ClaimRunClubScheduleParams {
  uid: string;
}

interface ReleaseUserScheduleParams extends ScheduleWindow {
  uid: string;
  runId: string;
}

interface ScheduleLockDoc {
  ownerType: LockOwner;
  ownerId: string;
  slot: number;
  runId: string;
  runClubId?: string;
  uid?: string;
  startTimeMillis: number;
  endTimeMillis: number;
}

/**
 * Validates the server-owned run duration invariant.
 * @param {number} startTimeMillis Run start in epoch milliseconds.
 * @param {number} endTimeMillis Run end in epoch milliseconds.
 */
export function assertValidRunTimeRange(
  startTimeMillis: number,
  endTimeMillis: number
) {
  if (endTimeMillis <= startTimeMillis) {
    throw new HttpsError(
      "invalid-argument",
      "Run end time must be after the start time."
    );
  }

  const durationMinutes = (endTimeMillis - startTimeMillis) / MINUTE_MS;
  if (durationMinutes > RUN_MAX_DURATION_MINUTES) {
    throw new HttpsError(
      "invalid-argument",
      `Runs cannot be longer than ${RUN_MAX_DURATION_MINUTES} minutes.`
    );
  }
}

/**
 * Claims server-owned run-club schedule locks for a new active run.
 * @param {FirebaseFirestore.Transaction} tx Firestore transaction.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {ClaimRunClubScheduleParams} params Run schedule params.
 */
export async function claimRunClubScheduleInTransaction(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  params: ClaimRunClubScheduleParams
) {
  assertValidRunTimeRange(params.startTimeMillis, params.endTimeMillis);
  await assertNoRunClubConflictByRunsQuery(tx, db, params);
  await claimLocksInTransaction(
    tx,
    db,
    runClubLockRefs(db, params.runClubId, params),
    params.runId,
    "This run club already has a run during that time.",
    (slot) => ({
      ownerType: "runClub",
      ownerId: params.runClubId,
      slot,
      runId: params.runId,
      runClubId: params.runClubId,
      startTimeMillis: params.startTimeMillis,
      endTimeMillis: params.endTimeMillis,
    })
  );
}

/**
 * Replaces run-club schedule locks after a host schedule edit.
 * @param {FirebaseFirestore.Transaction} tx Firestore transaction.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {ReplaceRunClubScheduleParams} params Run schedule params.
 */
export async function replaceRunClubScheduleInTransaction(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  params: ReplaceRunClubScheduleParams
) {
  assertValidRunTimeRange(params.startTimeMillis, params.endTimeMillis);
  await assertNoRunClubConflictByRunsQuery(tx, db, params);

  const nextRefs = runClubLockRefs(db, params.runClubId, params);
  await claimLocksInTransaction(
    tx,
    db,
    nextRefs,
    params.runId,
    "This run club already has a run during that time.",
    (slot) => ({
      ownerType: "runClub",
      ownerId: params.runClubId,
      slot,
      runId: params.runId,
      runClubId: params.runClubId,
      startTimeMillis: params.startTimeMillis,
      endTimeMillis: params.endTimeMillis,
    })
  );

  const nextSlots = new Set(nextRefs.map(({slot}) => slot));
  for (const {ref, slot} of runClubLockRefs(db, params.runClubId, {
    startTimeMillis: params.previousStartTimeMillis,
    endTimeMillis: params.previousEndTimeMillis,
  })) {
    if (!nextSlots.has(slot)) {
      tx.delete(ref);
    }
  }
}

/**
 * Releases run-club locks when a run is cancelled or hard-deleted.
 * @param {FirebaseFirestore.Transaction} tx Firestore transaction.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {ClaimRunClubScheduleParams} params Run schedule params.
 */
export function releaseRunClubScheduleInTransaction(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  params: ClaimRunClubScheduleParams
) {
  for (const {ref} of runClubLockRefs(db, params.runClubId, params)) {
    tx.delete(ref);
  }
}

/**
 * Claims a user's schedule for a signed-up or waitlisted run.
 * @param {FirebaseFirestore.Transaction} tx Firestore transaction.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {ClaimUserScheduleParams} params User schedule params.
 */
export async function claimUserRunScheduleInTransaction(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  params: ClaimUserScheduleParams
) {
  assertValidRunTimeRange(params.startTimeMillis, params.endTimeMillis);
  await assertNoUserConflictByParticipationQuery(tx, db, params);
  await claimLocksInTransaction(
    tx,
    db,
    userLockRefs(db, params.uid, params),
    params.runId,
    "You are already booked or waitlisted for another run at that time.",
    (slot) => ({
      ownerType: "user",
      ownerId: params.uid,
      slot,
      runId: params.runId,
      runClubId: params.runClubId,
      uid: params.uid,
      startTimeMillis: params.startTimeMillis,
      endTimeMillis: params.endTimeMillis,
    })
  );
}

/**
 * Releases user locks when a signup or waitlist edge is cancelled.
 * @param {FirebaseFirestore.Transaction} tx Firestore transaction.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {ReleaseUserScheduleParams} params User schedule params.
 */
export function releaseUserRunScheduleInTransaction(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  params: ReleaseUserScheduleParams
) {
  for (const {ref} of userLockRefs(db, params.uid, params)) {
    tx.delete(ref);
  }
}

/**
 * Checks paid-order preflight before creating a Razorpay order. The atomic
 * guard still lives in signUpUserForRun.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {ClaimUserScheduleParams} params User schedule params.
 */
export async function assertNoUserRunScheduleConflict(
  db: FirebaseFirestore.Firestore,
  params: ClaimUserScheduleParams
) {
  assertValidRunTimeRange(params.startTimeMillis, params.endTimeMillis);
  const refs = userLockRefs(db, params.uid, params);
  const lockSnaps = await Promise.all(refs.map(({ref}) => ref.get()));
  if (lockSnaps.some((snap) =>
    snap.exists && (snap.data() as ScheduleLockDoc | undefined)?.runId !==
      params.runId
  )) {
    throw new HttpsError(
      "failed-precondition",
      "You are already booked or waitlisted for another run at that time."
    );
  }

  const participationSnap = await db
    .collection("runParticipations")
    .where("uid", "==", params.uid)
    .where("status", "in", USER_SCHEDULE_STATUSES)
    .get();
  const runSnaps = await Promise.all(
    participationSnap.docs
      .map((doc) => doc.data().runId)
      .filter((runId): runId is string =>
        typeof runId === "string" && runId !== params.runId
      )
      .map((runId) => db.collection("runs").doc(runId).get())
  );
  if (runSnaps.some((snap) =>
    snap.exists &&
    runDocOverlaps(snap.data() as RunDoc, params.startTimeMillis,
      params.endTimeMillis)
  )) {
    throw new HttpsError(
      "failed-precondition",
      "You are already booked or waitlisted for another run at that time."
    );
  }
}

function scheduleSlots(params: ScheduleWindow): number[] {
  assertValidRunTimeRange(params.startTimeMillis, params.endTimeMillis);
  const slotMs = RUN_SCHEDULE_LOCK_SLOT_MINUTES * MINUTE_MS;
  const firstSlot = Math.floor(params.startTimeMillis / slotMs);
  const lastSlot = Math.floor((params.endTimeMillis - 1) / slotMs);
  const slots: number[] = [];
  for (let slot = firstSlot; slot <= lastSlot; slot += 1) {
    slots.push(slot);
  }
  return slots;
}

function runClubLockRefs(
  db: FirebaseFirestore.Firestore,
  runClubId: string,
  params: ScheduleWindow
) {
  return scheduleSlots(params).map((slot) => ({
    slot,
    ref: db.collection(RUN_CLUB_LOCK_COLLECTION)
      .doc(`${runClubId}_${slot}`),
  }));
}

function userLockRefs(
  db: FirebaseFirestore.Firestore,
  uid: string,
  params: ScheduleWindow
) {
  return scheduleSlots(params).map((slot) => ({
    slot,
    ref: db.collection(USER_LOCK_COLLECTION)
      .doc(`${uid}_${slot}`),
  }));
}

async function claimLocksInTransaction(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  refs: Array<{slot: number; ref: FirebaseFirestore.DocumentReference}>,
  runId: string,
  conflictMessage: string,
  buildDoc: (slot: number) => ScheduleLockDoc
) {
  void db;
  const snaps = await Promise.all(refs.map(({ref}) => tx.get(ref)));
  for (const snap of snaps) {
    const existing = snap.exists ?
      snap.data() as ScheduleLockDoc :
      null;
    if (existing && existing.runId !== runId) {
      throw new HttpsError("failed-precondition", conflictMessage);
    }
  }
  for (const {slot, ref} of refs) {
    tx.set(ref, buildDoc(slot));
  }
}

async function assertNoRunClubConflictByRunsQuery(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  params: ClaimRunClubScheduleParams
) {
  const snap = await tx.get(db
    .collection("runs")
    .where("runClubId", "==", params.runClubId)
    .where("status", "==", "active"));

  for (const doc of snap.docs) {
    if (doc.id === params.runId) continue;
    const run = doc.data() as RunDoc;
    if (runDocOverlaps(run, params.startTimeMillis, params.endTimeMillis)) {
      throw new HttpsError(
        "failed-precondition",
        "This run club already has a run during that time."
      );
    }
  }
}

async function assertNoUserConflictByParticipationQuery(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  params: ClaimUserScheduleParams
) {
  const participationSnap = await tx.get(db
    .collection("runParticipations")
    .where("uid", "==", params.uid)
    .where("status", "in", USER_SCHEDULE_STATUSES));

  for (const participation of participationSnap.docs) {
    const runId = participation.data().runId;
    if (typeof runId !== "string" || runId === params.runId) continue;
    const runSnap = await tx.get(db.collection("runs").doc(runId));
    if (!runSnap.exists) continue;
    const run = runSnap.data() as RunDoc;
    if (runDocOverlaps(run, params.startTimeMillis, params.endTimeMillis)) {
      throw new HttpsError(
        "failed-precondition",
        "You are already booked or waitlisted for another run at that time."
      );
    }
  }
}

function runDocOverlaps(
  run: RunDoc,
  startTimeMillis: number,
  endTimeMillis: number
): boolean {
  if (run.status === "cancelled") return false;
  return intervalsOverlap(
    startTimeMillis,
    endTimeMillis,
    run.startTime.toMillis(),
    run.endTime.toMillis()
  );
}

function intervalsOverlap(
  startA: number,
  endA: number,
  startB: number,
  endB: number
): boolean {
  return startA < endB && startB < endA;
}
