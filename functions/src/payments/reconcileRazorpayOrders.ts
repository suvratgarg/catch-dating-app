import {onSchedule} from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import Razorpay from "razorpay";
import {signUpUserForEvent} from "../events/signUpUserForEvent";
import {RazorpayPendingOrderDocument} from
  "../shared/generated/firestoreAdminTypes";
import {
  RazorpayPaymentSnapshot,
  verifyPaidEventBooking,
} from "./paymentValidation";
import {
  fulfillRazorpayPayment,
  markRazorpayPendingOrder,
  razorpayRefundFromClient,
} from "./razorpayFulfillment";
import {
  createRazorpayClient,
  razorpayKeyId,
  razorpayKeySecret,
} from "./razorpay";

const RECONCILE_GRACE_MS = 15 * 60 * 1000;
const RECONCILE_BATCH_LIMIT = 25;
const capturedStatuses = new Set(["authorized", "captured"]);

interface ReconcileDeps {
  firestore: () => FirebaseFirestore.Firestore;
  createClient: () => Razorpay;
  now: () => Date;
  timestampFromDate: (date: Date) => FirebaseFirestore.Timestamp;
  serverTimestamp: () => unknown;
  signUpForEvent: typeof signUpUserForEvent;
  graceMs: number;
  batchLimit: number;
}

const defaultDeps: ReconcileDeps = {
  firestore: () => admin.firestore(),
  createClient: createRazorpayClient,
  now: () => new Date(),
  timestampFromDate: (date) => admin.firestore.Timestamp.fromDate(date),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  signUpForEvent: signUpUserForEvent,
  graceMs: RECONCILE_GRACE_MS,
  batchLimit: RECONCILE_BATCH_LIMIT,
};

/**
 * Reconciliation sweep for stranded Razorpay orders.
 *
 * Closes the gap when BOTH the client verification callback AND the webhook are
 * missed: queries `razorpayPendingOrders` that are still "pending" and older
 * than the grace window, fetches each order's payments from Razorpay, and
 * either fulfills (if a captured/authorized payment exists) or marks the
 * tracking doc expired. Bounded by a batch limit so a backlog can't blow up a
 * single run. Fulfillment is the shared idempotent helper, so racing the
 * callback/webhook is safe.
 * @param {ReconcileDeps} deps Injectable dependencies.
 * @return {Promise<{processed: number, fulfilled: number, expired: number}>}
 *   Run summary.
 */
export async function reconcileRazorpayOrdersHandler(
  deps: ReconcileDeps = defaultDeps
): Promise<{processed: number; fulfilled: number; expired: number}> {
  const db = deps.firestore();
  const cutoff = deps.timestampFromDate(
    new Date(deps.now().getTime() - deps.graceMs)
  );

  const snap = await db
    .collection("razorpayPendingOrders")
    .where("status", "==", "pending")
    .where("createdAt", "<", cutoff)
    .orderBy("createdAt", "asc")
    .limit(deps.batchLimit)
    .get();

  if (snap.empty) return {processed: 0, fulfilled: 0, expired: 0};

  const razorpay = deps.createClient();
  let fulfilled = 0;
  let expired = 0;

  const results = await Promise.allSettled(
    snap.docs.map(async (doc) => {
      const pending = doc.data() as RazorpayPendingOrderDocument;
      const orderId = pending.orderId ?? doc.id;
      const outcome = await reconcileOrder({db, razorpay, deps, orderId});
      if (outcome === "fulfilled") fulfilled += 1;
      if (outcome === "expired") expired += 1;
    })
  );

  for (const result of results) {
    if (result.status === "rejected") {
      logger.error("Failed to reconcile Razorpay pending order", {
        reason: result.reason instanceof Error ?
          result.reason.message :
          String(result.reason),
      });
    }
  }

  return {processed: snap.docs.length, fulfilled, expired};
}

/**
 * Reconciles one stranded order against Razorpay's payment list.
 * @param {object} params Reconciliation parameters.
 * @return {Promise<"fulfilled"|"expired"|"skipped">} Outcome for tallies.
 */
async function reconcileOrder({
  db,
  razorpay,
  deps,
  orderId,
}: {
  db: FirebaseFirestore.Firestore;
  razorpay: Razorpay;
  deps: ReconcileDeps;
  orderId: string;
}): Promise<"fulfilled" | "expired" | "skipped"> {
  const [order, paymentsResult] = await Promise.all([
    razorpay.orders.fetch(orderId),
    razorpay.orders.fetchPayments(orderId),
  ]);
  const payments = (paymentsResult?.items ?? []) as RazorpayPaymentSnapshot[];
  const captured = payments.find((payment) =>
    capturedStatuses.has(payment.status)
  );

  if (!captured) {
    // No captured payment after the grace window — the user abandoned checkout
    // or the payment failed/was never made. Mark expired so we stop sweeping.
    await markRazorpayPendingOrder({
      db,
      orderId,
      status: "expired",
      serverTimestamp: deps.serverTimestamp,
    });
    return "expired";
  }

  const expectedUserId = noteString(
    order as {notes?: Record<string, unknown> | null},
    "userId"
  );
  if (!expectedUserId) {
    logger.error(
      "Razorpay reconciliation: order missing userId note",
      {orderId}
    );
    return "skipped";
  }

  const booking = verifyPaidEventBooking({
    order,
    payment: captured,
    expectedUserId,
  });

  await fulfillRazorpayPayment({
    db,
    orderId,
    paymentId: captured.id,
    booking,
    deps: {
      signUpForEvent: deps.signUpForEvent,
      refund: razorpayRefundFromClient(razorpay),
      serverTimestamp: deps.serverTimestamp,
    },
  });
  return "fulfilled";
}

/**
 * Reads a non-empty string note from a Razorpay order.
 * @param {object} order Razorpay order with optional notes map.
 * @param {string} key Note key.
 * @return {string|null} Note value when present.
 */
function noteString(
  order: {notes?: Record<string, unknown> | null},
  key: string
): string | null {
  const value = order.notes?.[key];
  if (typeof value !== "string") return null;
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : null;
}

export const reconcileRazorpayOrders = onSchedule(
  {
    schedule: "every 15 minutes",
    timeZone: "Asia/Kolkata",
    secrets: [razorpayKeyId, razorpayKeySecret],
  },
  async () => {
    try {
      const summary = await reconcileRazorpayOrdersHandler();
      if (summary.processed > 0) {
        logger.info("Razorpay reconciliation sweep completed", summary);
      }
    } catch (error) {
      logger.error("Razorpay reconciliation sweep failed", {error});
      throw error;
    }
  }
);
