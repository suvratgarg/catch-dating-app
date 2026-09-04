import * as admin from "firebase-admin";
import {onSchedule} from "firebase-functions/v2/scheduler";
import type {CrossPathsPairHoldDocument} from
  "../shared/generated/firestoreAdminTypes";
import {decrementCount} from "../events/eventPolicy";
import {requireDoc} from "../shared/validation";

export type PairHoldReleaseReason =
  "expired" | "cancelled" | "event_unavailable" |
  "participation_cancelled" | "safety_state_changed" | "payment_failed";

/** Releases a pair reservation exactly once inside an existing transaction. */
export async function releaseCrossPathsPairHoldInTransaction(params: {
  tx: FirebaseFirestore.Transaction;
  db: FirebaseFirestore.Firestore;
  holdId: string;
  reason: PairHoldReleaseReason;
  now: FirebaseFirestore.Timestamp;
}): Promise<CrossPathsPairHoldDocument | null> {
  const holdRef = params.db.collection("crossPathsPairHolds")
    .doc(params.holdId);
  const holdSnap = await params.tx.get(holdRef);
  if (!holdSnap.exists) return null;
  const hold = requireDoc<CrossPathsPairHoldDocument>(
    holdSnap,
    "CrossPathsPairHoldDocument (release)"
  );
  if (hold.status !== "active" && hold.status !== "confirmed") return hold;

  const eventRef = params.db.collection("events").doc(hold.eventId);
  const eventSnap = await params.tx.get(eventRef);
  if (eventSnap.exists) {
    const event = eventSnap.data() ?? {};
    const eventUpdate: Record<string, unknown> = {};
    if (hold.status === "active") {
      eventUpdate.crossPathsPairHeldCount = Math.max(
        0,
        Math.trunc(Number(event.crossPathsPairHeldCount ?? 0)) - 1
      );
      eventUpdate.crossPathsPairHeldCohortCounts = decrementCount(
        event.crossPathsPairHeldCohortCounts as Record<string, number> ?? {},
        hold.requesterCohortId
      );
    } else {
      eventUpdate.crossPathsPairConfirmedCount = Math.max(
        0,
        Math.trunc(Number(event.crossPathsPairConfirmedCount ?? 0)) - 1
      );
    }
    params.tx.update(eventRef, eventUpdate);
  }

  const terminalStatus = params.reason === "expired" ? "expired" :
    params.reason === "cancelled" ? "cancelled" : "invalidated";
  params.tx.update(holdRef, {
    status: terminalStatus,
    requesterBookingStatus: hold.status === "active" ? "cancelled" :
      hold.requesterBookingStatus,
    updatedAt: params.now,
    releasedAt: params.now,
    releaseReason: params.reason,
  });
  return hold;
}

/** Releases one hold in its own idempotent transaction. */
export async function releaseCrossPathsPairHold(params: {
  db: FirebaseFirestore.Firestore;
  holdId: string;
  reason: PairHoldReleaseReason;
  now?: FirebaseFirestore.Timestamp;
}): Promise<CrossPathsPairHoldDocument | null> {
  const now = params.now ?? admin.firestore.Timestamp.now();
  let released: CrossPathsPairHoldDocument | null = null;
  await params.db.runTransaction(async (tx) => {
    released = await releaseCrossPathsPairHoldInTransaction({
      tx,
      db: params.db,
      holdId: params.holdId,
      reason: params.reason,
      now,
    });
  });
  return released;
}

/** Expires short-lived pair reservations and returns capacity to the event. */
export const expireCrossPathsPairHolds = onSchedule(
  {schedule: "every 5 minutes", timeZone: "UTC"},
  async () => {
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();
    const snap = await db.collection("crossPathsPairHolds")
      .where("status", "==", "active")
      .where("expiresAt", "<=", now)
      .limit(400)
      .get();
    for (const doc of snap.docs) {
      const hold = await releaseCrossPathsPairHold({
        db,
        holdId: doc.id,
        reason: "expired",
        now,
      });
      if (!hold) continue;
      await db.collection("crossPathsInvitations")
        .doc(hold.invitationId).set({
          status: "invalidated",
          updatedAt: now,
          invalidatedAt: now,
          invalidationReason: "hold_expired",
        }, {merge: true});
    }
  }
);
