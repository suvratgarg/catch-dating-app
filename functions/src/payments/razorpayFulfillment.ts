import * as logger from "firebase-functions/logger";
import {signUpUserForEvent} from "../events/signUpUserForEvent";
import {eventParticipationId} from "../shared/relationshipDocuments";
import {hasHostApprovedJoinRequest} from "../events/eventPolicy";
import {
  InviteAttribution,
} from "../events/inviteLinks";
import {VerifiedPaymentBooking} from "./paymentValidation";
import {NativePaidBooking, stageRejectedNativeBooking} from "./nativeBooking";
import {releaseCrossPathsPairHold} from "../crossPaths/pairHolds";

export interface RazorpayFulfillmentDeps {
  signUpForEvent: typeof signUpUserForEvent;
  serverTimestamp: () => unknown;
}

/**
 * Terminal payment states. Re-running fulfillment for any of these is a no-op
 * so the client callback, webhook, and reconciliation sweep can all race
 * without double-fulfilling or double-charging.
 */
const terminalPaymentStatuses = new Set([
  "completed",
  "refunded",
  "refundFailed",
]);

/** Commit admission/payment together; persist refunds for rejected bookings. */
export async function fulfillRazorpayPayment({
  db,
  orderId,
  paymentId,
  booking,
  deps,
}: {
  db: FirebaseFirestore.Firestore;
  orderId: string;
  paymentId: string;
  booking: VerifiedPaymentBooking;
  deps: RazorpayFulfillmentDeps;
}): Promise<{fulfilled: boolean; alreadyFinalized: boolean}> {
  const inviteAttribution = inviteAttributionFromBooking(booking);
  const paymentRef = db.collection("payments").doc(paymentId);
  const existingPaymentSnap = await paymentRef.get();
  const existingStatus = existingPaymentSnap.data()?.status as
    | string
    | undefined;

  // Idempotency: any already-finalized payment is a no-op for every caller.
  if (
    existingStatus !== undefined &&
    terminalPaymentStatuses.has(existingStatus)
  ) {
    await deletePendingOrderBestEffort(db, orderId);
    return {fulfilled: existingStatus === "completed", alreadyFinalized: true};
  }

  const paidBooking: NativePaidBooking = {
    userId: booking.userId, orderId, paymentId, eventId: booking.eventId,
    amount: booking.amountInPaise, amountMinor: booking.amountInPaise,
    currency: booking.currency, provider: "razorpay",
    ...(booking.inviteLinkId ? {inviteLinkId: booking.inviteLinkId} : {}),
    ...(booking.inviteSource ? {inviteSource: booking.inviteSource} : {}),
    ...(booking.crossPathsPairHoldId ?
      {crossPathsPairHoldId: booking.crossPathsPairHoldId} : {}),
  };
  try {
    const participationSnap = await db
      .collection("eventParticipations")
      .doc(eventParticipationId(booking.eventId, booking.userId))
      .get();
    const hasHostApproval =
      hasHostApprovedJoinRequest(participationSnap.data());
    await deps.signUpForEvent(db, booking.eventId, booking.userId, paymentId, {
      paidBooking,
      hasValidInvite: booking.inviteVerified,
      ...(hasHostApproval ? {hasHostApproval} : {}),
      ...(inviteAttribution ? {inviteAttribution} : {}),
      ...(booking.crossPathsPairHoldId ?
        {crossPathsPairHoldId: booking.crossPathsPairHoldId} : {}),
    });
  } catch (signUpError) {
    const outcome = await stageRejectedNativeBooking({db,
      booking: paidBooking});
    if (outcome === "admitted") {
      await deletePendingOrderBestEffort(db, orderId);
      return {fulfilled: true, alreadyFinalized: true};
    }
    if (booking.crossPathsPairHoldId) {
      await releaseCrossPathsPairHold({
        db,
        holdId: booking.crossPathsPairHoldId,
        reason: "payment_failed",
      });
    }

    // The durable payment refund queue now owns recovery.
    await deletePendingOrderBestEffort(db, orderId);

    throw signUpError;
  }

  await deletePendingOrderBestEffort(db, orderId);

  return {fulfilled: true, alreadyFinalized: false};
}

/**
 * Deletes the pending-order tracking doc once the payment is finalized.
 * Best effort — a stranded pending doc is harmless (the sweep re-checks and
 * finds the completed payment), so a delete failure must not fail fulfillment.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {string} orderId Razorpay order id.
 * @return {Promise<void>} Resolves when the delete settles.
 */
async function deletePendingOrderBestEffort(
  db: FirebaseFirestore.Firestore,
  orderId: string
): Promise<void> {
  try {
    await db.collection("razorpayPendingOrders").doc(orderId).delete();
  } catch (error) {
    logger.warn(
      "Failed to delete fulfilled Razorpay pending order",
      {orderId},
      error
    );
  }
}

/**
 * Converts verified booking metadata into invite attribution.
 * @param {VerifiedPaymentBooking} booking Verified booking metadata.
 * @return {InviteAttribution|null} Invite attribution when available.
 */
export function inviteAttributionFromBooking(booking: {
  inviteLinkId?: string | null;
  inviteSource?: string | null;
}): InviteAttribution | null {
  return booking.inviteLinkId ? {
    inviteLinkId: booking.inviteLinkId,
    inviteSource: booking.inviteSource ?? null,
  } : null;
}

/**
 * Writes a tracking doc for a freshly created Razorpay order so reconciliation
 * can recover the booking if the verification callback never lands.
 * @param {object} params Pending order parameters.
 * @return {Promise<void>} Resolves when the doc is written.
 */
export async function writeRazorpayPendingOrder({
  db,
  orderId,
  userId,
  eventId,
  amountInPaise,
  currency,
  serverTimestamp,
  crossPathsPairHoldId,
}: {
  db: FirebaseFirestore.Firestore;
  orderId: string;
  userId: string;
  eventId: string;
  amountInPaise: number;
  currency: string;
  serverTimestamp: () => unknown;
  crossPathsPairHoldId?: string | null;
}): Promise<void> {
  await db.collection("razorpayPendingOrders").doc(orderId).set({
    provider: "razorpay" as const,
    orderId,
    userId,
    eventId,
    amountInPaise,
    currency,
    ...(crossPathsPairHoldId ? {crossPathsPairHoldId} : {}),
    status: "pending" as const,
    createdAt: serverTimestamp(),
  });
}

/**
 * Permitted source statuses for each {@link markRazorpayPendingOrder} target.
 *
 * - `failed` (webhook payment.failed) may only advance a still-`pending` order,
 *   so a stray late payment.failed can never resurrect an already-`expired` or
 *   fulfilled-then-deleted order.
 * - `expired` (reconciliation, no captured payment) may settle both a `pending`
 *   order (abandoned checkout) and a `failed` one (a failed attempt that was
 *   never recaptured), giving the sweep a terminal state to retire either into.
 *
 * Crucially `failed` is NOT terminal: a `failed` order stays sweep-eligible
 * (see the reconciliation query) so a later same-order recapture can fulfill.
 */
const pendingOrderTransitions: Record<"failed" | "expired", Set<string>> = {
  failed: new Set(["pending"]),
  expired: new Set(["pending", "failed"]),
};

/**
 * Marks a pending order failed/expired without touching the canonical payments
 * record. Used by the webhook (payment.failed) and the reconciliation sweep (no
 * captured payment after the grace window). Only advances the doc along a
 * permitted transition (see {@link pendingOrderTransitions}); any other current
 * status is a no-op.
 * @param {object} params Update parameters.
 * @return {Promise<void>} Resolves when the doc settles.
 */
export async function markRazorpayPendingOrder({
  db,
  orderId,
  status,
  serverTimestamp,
}: {
  db: FirebaseFirestore.Firestore;
  orderId: string;
  status: "failed" | "expired";
  serverTimestamp: () => unknown;
}): Promise<void> {
  const ref = db.collection("razorpayPendingOrders").doc(orderId);
  const snap = await ref.get();
  if (!snap.exists) return;
  const current = snap.data()?.status as string | undefined;
  if (current === undefined || !pendingOrderTransitions[status].has(current)) {
    return;
  }
  await ref.set({
    status,
    updatedAt: serverTimestamp(),
  }, {merge: true});
}
