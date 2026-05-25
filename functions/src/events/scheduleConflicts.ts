/* eslint-disable require-jsdoc */
import {HttpsError} from "firebase-functions/v2/https";
import {EventDoc} from "../shared/generated/firestoreAdminTypes";
import {
  EVENT_MAX_DURATION_MINUTES,
  EVENT_SCHEDULE_LOCK_SLOT_MINUTES,
} from "../shared/businessRules";

const MINUTE_MS = 60 * 1000;
const CLUB_LOCK_COLLECTION = "clubScheduleLocks";
const USER_LOCK_COLLECTION = "userEventScheduleLocks";
const USER_SCHEDULE_STATUSES = ["signedUp", "waitlisted", "attended"];

type LockOwner = "club" | "user";

interface ScheduleWindow {
  startTimeMillis: number;
  endTimeMillis: number;
}

interface ClaimClubScheduleParams extends ScheduleWindow {
  clubId: string;
  eventId: string;
}

interface ReplaceClubScheduleParams extends ClaimClubScheduleParams {
  previousStartTimeMillis: number;
  previousEndTimeMillis: number;
}

interface ClaimUserScheduleParams extends ClaimClubScheduleParams {
  uid: string;
}

interface ReleaseUserScheduleParams extends ScheduleWindow {
  uid: string;
  eventId: string;
}

interface ScheduleLockDoc {
  ownerType: LockOwner;
  ownerId: string;
  slot: number;
  eventId: string;
  clubId?: string;
  uid?: string;
  startTimeMillis: number;
  endTimeMillis: number;
}

/**
 * Validates the server-owned event duration invariant.
 * @param {number} startTimeMillis Event start in epoch milliseconds.
 * @param {number} endTimeMillis Event end in epoch milliseconds.
 */
export function assertValidEventTimeRange(
  startTimeMillis: number,
  endTimeMillis: number
) {
  if (endTimeMillis <= startTimeMillis) {
    throw new HttpsError(
      "invalid-argument",
      "Event end time must be after the start time."
    );
  }

  const durationMinutes = (endTimeMillis - startTimeMillis) / MINUTE_MS;
  if (durationMinutes > EVENT_MAX_DURATION_MINUTES) {
    throw new HttpsError(
      "invalid-argument",
      `Events cannot be longer than ${EVENT_MAX_DURATION_MINUTES} minutes.`
    );
  }
}

/**
 * Claims server-owned club schedule locks for a new active event.
 * @param {FirebaseFirestore.Transaction} tx Firestore transaction.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {ClaimClubScheduleParams} params Event schedule params.
 */
export async function claimClubScheduleInTransaction(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  params: ClaimClubScheduleParams
) {
  assertValidEventTimeRange(params.startTimeMillis, params.endTimeMillis);
  await assertNoClubConflictByEventsQuery(tx, db, params);
  await claimLocksInTransaction(
    tx,
    db,
    clubLockRefs(db, params.clubId, params),
    params.eventId,
    "This club already has an event during that time.",
    (slot) => ({
      ownerType: "club",
      ownerId: params.clubId,
      slot,
      eventId: params.eventId,
      clubId: params.clubId,
      startTimeMillis: params.startTimeMillis,
      endTimeMillis: params.endTimeMillis,
    })
  );
}

/**
 * Replaces club schedule locks after a host schedule edit.
 * @param {FirebaseFirestore.Transaction} tx Firestore transaction.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {ReplaceClubScheduleParams} params Event schedule params.
 */
export async function replaceClubScheduleInTransaction(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  params: ReplaceClubScheduleParams
) {
  assertValidEventTimeRange(params.startTimeMillis, params.endTimeMillis);
  await assertNoClubConflictByEventsQuery(tx, db, params);

  const nextRefs = clubLockRefs(db, params.clubId, params);
  await claimLocksInTransaction(
    tx,
    db,
    nextRefs,
    params.eventId,
    "This club already has an event during that time.",
    (slot) => ({
      ownerType: "club",
      ownerId: params.clubId,
      slot,
      eventId: params.eventId,
      clubId: params.clubId,
      startTimeMillis: params.startTimeMillis,
      endTimeMillis: params.endTimeMillis,
    })
  );

  const nextSlots = new Set(nextRefs.map(({slot}) => slot));
  for (const {ref, slot} of clubLockRefs(db, params.clubId, {
    startTimeMillis: params.previousStartTimeMillis,
    endTimeMillis: params.previousEndTimeMillis,
  })) {
    if (!nextSlots.has(slot)) {
      tx.delete(ref);
    }
  }
}

/**
 * Releases club locks when an event is cancelled or hard-deleted.
 * @param {FirebaseFirestore.Transaction} tx Firestore transaction.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {ClaimClubScheduleParams} params Event schedule params.
 */
export function releaseClubScheduleInTransaction(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  params: ClaimClubScheduleParams
) {
  for (const {ref} of clubLockRefs(db, params.clubId, params)) {
    tx.delete(ref);
  }
}

/**
 * Claims a user's schedule for a signed-up or waitlisted event.
 * @param {FirebaseFirestore.Transaction} tx Firestore transaction.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {ClaimUserScheduleParams} params User schedule params.
 */
export async function claimUserEventScheduleInTransaction(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  params: ClaimUserScheduleParams
) {
  assertValidEventTimeRange(params.startTimeMillis, params.endTimeMillis);
  await assertNoUserConflictByParticipationQuery(tx, db, params);
  await claimLocksInTransaction(
    tx,
    db,
    userLockRefs(db, params.uid, params),
    params.eventId,
    "You are already booked or waitlisted for another event at that time.",
    (slot) => ({
      ownerType: "user",
      ownerId: params.uid,
      slot,
      eventId: params.eventId,
      clubId: params.clubId,
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
export function releaseUserEventScheduleInTransaction(
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
 * guard still lives in signUpUserForEvent.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {ClaimUserScheduleParams} params User schedule params.
 */
export async function assertNoUserEventScheduleConflict(
  db: FirebaseFirestore.Firestore,
  params: ClaimUserScheduleParams
) {
  assertValidEventTimeRange(params.startTimeMillis, params.endTimeMillis);
  const refs = userLockRefs(db, params.uid, params);
  const lockSnaps = await Promise.all(refs.map(({ref}) => ref.get()));
  if (lockSnaps.some((snap) =>
    snap.exists && (snap.data() as ScheduleLockDoc | undefined)?.eventId !==
      params.eventId
  )) {
    throw new HttpsError(
      "failed-precondition",
      "You are already booked or waitlisted for another event at that time."
    );
  }

  const participationSnap = await db
    .collection("eventParticipations")
    .where("uid", "==", params.uid)
    .where("status", "in", USER_SCHEDULE_STATUSES)
    .get();
  const eventSnaps = await Promise.all(
    participationSnap.docs
      .map((doc) => doc.data().eventId)
      .filter((eventId): eventId is string =>
        typeof eventId === "string" && eventId !== params.eventId
      )
      .map((eventId) => db.collection("events").doc(eventId).get())
  );
  if (eventSnaps.some((snap) =>
    snap.exists &&
    eventDocOverlaps(snap.data() as EventDoc, params.startTimeMillis,
      params.endTimeMillis)
  )) {
    throw new HttpsError(
      "failed-precondition",
      "You are already booked or waitlisted for another event at that time."
    );
  }
}

function scheduleSlots(params: ScheduleWindow): number[] {
  assertValidEventTimeRange(params.startTimeMillis, params.endTimeMillis);
  const slotMs = EVENT_SCHEDULE_LOCK_SLOT_MINUTES * MINUTE_MS;
  const firstSlot = Math.floor(params.startTimeMillis / slotMs);
  const lastSlot = Math.floor((params.endTimeMillis - 1) / slotMs);
  const slots: number[] = [];
  for (let slot = firstSlot; slot <= lastSlot; slot += 1) {
    slots.push(slot);
  }
  return slots;
}

function clubLockRefs(
  db: FirebaseFirestore.Firestore,
  clubId: string,
  params: ScheduleWindow
) {
  return scheduleSlots(params).map((slot) => ({
    slot,
    ref: db.collection(CLUB_LOCK_COLLECTION)
      .doc(`${clubId}_${slot}`),
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
  eventId: string,
  conflictMessage: string,
  buildDoc: (slot: number) => ScheduleLockDoc
) {
  void db;
  const snaps = await Promise.all(refs.map(({ref}) => tx.get(ref)));
  for (const snap of snaps) {
    const existing = snap.exists ?
      snap.data() as ScheduleLockDoc :
      null;
    if (existing && existing.eventId !== eventId) {
      throw new HttpsError("failed-precondition", conflictMessage);
    }
  }
  for (const {slot, ref} of refs) {
    tx.set(ref, buildDoc(slot));
  }
}

async function assertNoClubConflictByEventsQuery(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  params: ClaimClubScheduleParams
) {
  const snap = await tx.get(db
    .collection("events")
    .where("clubId", "==", params.clubId)
    .where("status", "==", "active"));

  for (const doc of snap.docs) {
    if (doc.id === params.eventId) continue;
    const event = doc.data() as EventDoc;
    if (eventDocOverlaps(event, params.startTimeMillis, params.endTimeMillis)) {
      throw new HttpsError(
        "failed-precondition",
        "This club already has an event during that time."
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
    .collection("eventParticipations")
    .where("uid", "==", params.uid)
    .where("status", "in", USER_SCHEDULE_STATUSES));

  for (const participation of participationSnap.docs) {
    const eventId = participation.data().eventId;
    if (typeof eventId !== "string" || eventId === params.eventId) continue;
    const eventSnap = await tx.get(db.collection("events").doc(eventId));
    if (!eventSnap.exists) continue;
    const event = eventSnap.data() as EventDoc;
    if (eventDocOverlaps(event, params.startTimeMillis, params.endTimeMillis)) {
      throw new HttpsError(
        "failed-precondition",
        "You are already booked or waitlisted for another event at that time."
      );
    }
  }
}

function eventDocOverlaps(
  event: EventDoc,
  startTimeMillis: number,
  endTimeMillis: number
): boolean {
  if (event.status === "cancelled") return false;
  return intervalsOverlap(
    startTimeMillis,
    endTimeMillis,
    event.startTime.toMillis(),
    event.endTime.toMillis()
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
