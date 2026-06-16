import * as logger from "firebase-functions/logger";
import {signUpUserForEvent} from "../events/signUpUserForEvent";
import {eventParticipationId} from "../shared/relationshipDocuments";
import {hasHostApprovedJoinRequest} from "../events/eventPolicy";
import {
  incrementInviteLinkCounterBestEffort,
  InviteAttribution,
} from "../events/inviteLinks";
import {buildPaymentRecord, VerifiedPaymentBooking} from "./paymentValidation";

/**
 * Issues a Razorpay refund for a payment that could not be fulfilled.
 * Returns whether the refund succeeded so callers can pick the wire status.
 */
export type RazorpayRefund = (
  paymentId: string,
  amountInPaise: number
) => Promise<void>;

export interface RazorpayFulfillmentDeps {
  signUpForEvent: typeof signUpUserForEvent;
  refund: RazorpayRefund;
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

/**
 * Shared Razorpay payment fulfillment.
 *
 * Signs the user up for the event and writes the canonical
 * `payments/{paymentId}` "completed" record (plus a best-effort invite
 * paidCount increment).
 * If sign-up fails (e.g. the event filled up after order creation), issues an
 * immediate refund and records "refunded", or "refundFailed" with an alert log
 * when the refund itself fails.
 *
 * Idempotent: if the payment doc is already in a terminal state
 * (completed/refunded/refundFailed) this returns immediately without touching
 * Razorpay or Firestore, and signUpUserForEvent's own existing-participation
 * guard protects against partial-write races. Safe to call from the client
 * callback, the webhook, and the reconciliation sweep.
 *
 * On success the matching `razorpayPendingOrders/{orderId}` tracking doc is
 * deleted (best effort) so reconciliation stops considering the order stranded.
 *
 * @param {object} params Fulfillment parameters.
 * @param {FirebaseFirestore.Firestore} params.db Firestore instance.
 * @param {string} params.orderId Razorpay order id.
 * @param {string} params.paymentId Razorpay payment id.
 * @param {VerifiedPaymentBooking} params.booking Verified booking truth.
 * @param {RazorpayFulfillmentDeps} params.deps Injectable dependencies.
 * @return {Promise<{fulfilled: boolean, alreadyFinalized: boolean}>} Outcome.
 */
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

  const shouldIncrementPaidCount =
    inviteAttribution !== null && existingStatus !== "completed";

  // Sign the user up. If this fails (e.g. event filled up in a race between
  // order creation and payment), issue an immediate refund so the user is
  // never charged for a spot they didn't get.
  try {
    const participationSnap = await db
      .collection("eventParticipations")
      .doc(eventParticipationId(booking.eventId, booking.userId))
      .get();
    const hasHostApproval =
      hasHostApprovedJoinRequest(participationSnap.data());
    await deps.signUpForEvent(db, booking.eventId, booking.userId, paymentId, {
      hasValidInvite: booking.inviteVerified,
      ...(hasHostApproval ? {hasHostApproval} : {}),
      ...(inviteAttribution ? {inviteAttribution} : {}),
    });
  } catch (signUpError) {
    let refundSucceeded = false;
    try {
      await deps.refund(paymentId, booking.amountInPaise);
      refundSucceeded = true;
    } catch (refundError) {
      // The user was charged, the booking failed, AND we could not refund.
      // Flag a distinct non-recoverable state so reconciliation can find it.
      logger.error(
        "ALERT manual refund required: Razorpay refund failed",
        {paymentId, orderId, userId: booking.userId, eventId: booking.eventId},
        refundError
      );
    }

    await paymentRef.set({
      ...buildPaymentRecord({
        userId: booking.userId,
        orderId,
        paymentId,
        eventId: booking.eventId,
        amountInPaise: booking.amountInPaise,
        currency: booking.currency,
        status: refundSucceeded ? "refunded" : "refundFailed",
        signUpFailed: true,
        inviteLinkId: booking.inviteLinkId,
        inviteSource: booking.inviteSource,
      }),
      createdAt: deps.serverTimestamp(),
    });

    // The order reached a terminal (refunded/refundFailed) state — stop the
    // reconciliation sweep from re-processing it.
    await deletePendingOrderBestEffort(db, orderId);

    throw signUpError;
  }

  // Record the completed payment.
  if (shouldIncrementPaidCount && inviteAttribution) {
    await incrementInviteLinkCounterBestEffort({
      db,
      inviteLinkId: inviteAttribution.inviteLinkId,
      field: "paidCount",
    });
  }

  await paymentRef.set({
    ...buildPaymentRecord({
      userId: booking.userId,
      orderId,
      paymentId,
      eventId: booking.eventId,
      amountInPaise: booking.amountInPaise,
      currency: booking.currency,
      status: "completed",
      inviteLinkId: booking.inviteLinkId,
      inviteSource: booking.inviteSource,
    }),
    createdAt: deps.serverTimestamp(),
  });

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
 * Default refund function bound to a Razorpay SDK client.
 * @param {import("razorpay")} razorpay Razorpay SDK client.
 * @return {RazorpayRefund} Refund function for the fulfillment helper.
 */
export function razorpayRefundFromClient(razorpay: {
  payments: {refund: (id: string, opts: {amount: number}) => unknown};
}): RazorpayRefund {
  return async (paymentId: string, amountInPaise: number) => {
    await razorpay.payments.refund(paymentId, {amount: amountInPaise});
  };
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
}: {
  db: FirebaseFirestore.Firestore;
  orderId: string;
  userId: string;
  eventId: string;
  amountInPaise: number;
  currency: string;
  serverTimestamp: () => unknown;
}): Promise<void> {
  await db.collection("razorpayPendingOrders").doc(orderId).set({
    provider: "razorpay" as const,
    orderId,
    userId,
    eventId,
    amountInPaise,
    currency,
    status: "pending" as const,
    createdAt: serverTimestamp(),
  });
}

/**
 * Marks a pending order terminal (failed/expired) without touching the
 * canonical payments record. Used by the webhook (payment.failed) and the
 * reconciliation sweep (no captured payment after the grace window).
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
  await ref.set({
    status,
    updatedAt: serverTimestamp(),
  }, {merge: true});
}
