import {onSchedule} from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import Razorpay from "razorpay";
import {signUpUserForEvent} from "../events/signUpUserForEvent";
import type {
  NativeRefundRecoveryCursorDocument,
  RazorpayPendingOrderDocument,
} from "../shared/generated/firestoreAdminTypes";
import {validateNativeRefundRecoveryCursorDocument} from
  "../shared/generated/validators/nativeRefundRecoveryCursorDocument";
import {
  RazorpayPaymentSnapshot,
  verifyPaidEventBooking,
} from "./paymentValidation";
import {
  fulfillRazorpayPayment,
  markRazorpayPendingOrder,
} from "./razorpayFulfillment";
import {
  createRazorpayClient,
  razorpayKeySecret,
} from "./razorpay";
import {
  assertRazorpayOrderOwnership,
  razorpayRuntimeProject,
  resolveRazorpayOrderOwnership,
} from "./razorpayOrderOwnership";

const RECONCILE_GRACE_MS = 15 * 60 * 1000;
const RECONCILE_BATCH_LIMIT = 25;
const RECONCILE_CURSOR_COLLECTION = "nativeRefundRecoveryCursors";
const RECONCILE_CURSOR_STATE_ID = "pendingRazorpayOrders";
const capturedStatuses = new Set(["captured"]);

type ReconcileContinuation = NonNullable<
  NativeRefundRecoveryCursorDocument["cursor"]>;

interface LoadedReconcileCursor {
  revision: number;
  cursor?: ReconcileContinuation;
}

interface ReconcileDeps {
  firestore: () => FirebaseFirestore.Firestore;
  createClient: () => Razorpay;
  now: () => Date;
  timestampFromDate: (date: Date) => FirebaseFirestore.Timestamp;
  serverTimestamp: () => unknown;
  signUpForEvent: typeof signUpUserForEvent;
  graceMs: number;
  batchLimit: number;
  runtimeProjectId?: () => string;
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
  runtimeProjectId: razorpayRuntimeProject,
};

/**
 * Reconciliation sweep for stranded Razorpay orders.
 *
 * Closes the gap when BOTH the client verification callback AND the webhook are
 * missed: queries `razorpayPendingOrders` that are still "pending" and older
 * than the grace window, fetches each order's payments from Razorpay, and
 * either fulfills a captured payment, waits for capture, or marks the
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
  const now = deps.now();
  const cutoff = deps.timestampFromDate(
    new Date(now.getTime() - deps.graceMs)
  );
  const runtimeProjectId =
    (deps.runtimeProjectId ?? razorpayRuntimeProject)();
  const durable = await openReconcileCursor({db, runtimeProjectId,
    nowMillis: now.getTime()});

  // Sweep both "pending" (never resolved) and "failed" (a payment.failed
  // webhook landed, but the user may have retried and a later attempt on the
  // SAME order could still be captured). Including "failed" closes the gap
  // where a failed-then-recaptured order would otherwise be stranded — see
  // markRazorpayPendingOrder: "failed" is intentionally non-terminal. Orders
  // settle to "expired" (terminal, not swept) once the grace window passes with
  // no capture, so this can't sweep the same doc forever.
  let query = db
    .collection("razorpayPendingOrders")
    .where("status", "in", ["pending", "failed"])
    .where("createdAt", "<", cutoff)
    .orderBy("createdAt", "asc")
    .orderBy(admin.firestore.FieldPath.documentId())
    .limit(deps.batchLimit);
  if (durable.continuation) {
    const start = decodeReconcileContinuation(durable.continuation);
    query = query.startAfter(start.createdAt, start.orderId);
  }
  const snap = await query.get();

  if (snap.empty) {
    if (durable.continuation) await durable.checkpoint(undefined);
    return {processed: 0, fulfilled: 0, expired: 0};
  }

  const discoveredContinuation = encodeReconcileContinuation(
    snap.docs.at(-1)!
  );
  // Advance discovery before provider I/O. A killed invocation resumes after
  // this bounded page; a completed short page wraps below, so unavailable or
  // quarantined rows retry without permanently hiding later owned work.
  await durable.checkpoint(discoveredContinuation);

  const razorpay = deps.createClient();
  let fulfilled = 0;
  let expired = 0;

  const results = await Promise.allSettled(
    snap.docs.map(async (doc) => {
      const pending = doc.data() as RazorpayPendingOrderDocument;
      const orderId = pending.orderId ?? doc.id;
      const outcome = await reconcileOrder({db, razorpay, deps, orderId,
        pending, runtimeProjectId});
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

  // Only wrap after the short tail completed. If this invocation is killed
  // during provider work, its committed tail survives and the next run first
  // closes that page instead of returning to quarantined oldest rows.
  if (snap.docs.length < deps.batchLimit) {
    await durable.checkpoint(undefined);
  }

  return {processed: snap.docs.length, fulfilled, expired};
}

/** Opens project-bound durable discovery for bounded reconciliation. */
async function openReconcileCursor(input: {
  db: FirebaseFirestore.Firestore;
  runtimeProjectId: string;
  nowMillis: number;
}): Promise<{continuation?: ReconcileContinuation;
  checkpoint: (cursor?: ReconcileContinuation) => Promise<void>}> {
  const {db, runtimeProjectId, nowMillis} = input;
  const stateRef = db.collection(RECONCILE_CURSOR_COLLECTION)
    .doc(RECONCILE_CURSOR_STATE_ID);
  let expected = await db.runTransaction(async (tx) =>
    readReconcileCursor(await tx.get(stateRef), runtimeProjectId));
  return {continuation: expected.cursor, checkpoint: async (cursor) => {
    const next = await db.runTransaction(async (tx) => {
      const current = readReconcileCursor(await tx.get(stateRef),
        runtimeProjectId);
      if (current.revision !== expected.revision ||
          !sameReconcileContinuation(current.cursor, expected.cursor)) {
        throw new Error("Razorpay reconciliation cursor changed.");
      }
      const revision = expected.revision + 1;
      const document: NativeRefundRecoveryCursorDocument = {
        stateId: RECONCILE_CURSOR_STATE_ID,
        projectId: runtimeProjectId,
        schema: "1",
        revision,
        cursor: cursor ?? null,
        updatedAtMillis: nowMillis,
      };
      tx.set(stateRef, document);
      return {revision, cursor} satisfies LoadedReconcileCursor;
    });
    expected = next;
  }};
}

function readReconcileCursor(
  snapshot: FirebaseFirestore.DocumentSnapshot,
  runtimeProjectId: string
): LoadedReconcileCursor {
  if (!snapshot.exists) return {revision: 0};
  const value = snapshot.data();
  if (!validateNativeRefundRecoveryCursorDocument(value)) {
    throw new Error("Razorpay reconciliation cursor is malformed.");
  }
  const state = value;
  if (state.stateId !== RECONCILE_CURSOR_STATE_ID ||
      state.schema !== "1" || state.projectId !== runtimeProjectId) {
    throw new Error("Razorpay reconciliation cursor authority is invalid.");
  }
  if (state.cursor) decodeReconcileContinuation(state.cursor);
  return {revision: state.revision,
    ...(state.cursor ? {cursor: state.cursor} : {})};
}

function encodeReconcileContinuation(
  snapshot: FirebaseFirestore.QueryDocumentSnapshot
): ReconcileContinuation {
  const createdAt = (snapshot.data() as RazorpayPendingOrderDocument).createdAt;
  if (!Number.isSafeInteger(createdAt.seconds) ||
      !Number.isInteger(createdAt.nanoseconds) ||
      createdAt.nanoseconds < 0 || createdAt.nanoseconds > 999_999_999) {
    throw new Error("Razorpay reconciliation timestamp is malformed.");
  }
  if (snapshot.id.length === 0 || snapshot.id.includes("/") ||
      Buffer.byteLength(snapshot.id, "utf8") > 1500) {
    throw new Error("Razorpay reconciliation document id is malformed.");
  }
  const epochNanoseconds = BigInt(createdAt.seconds) * 1_000_000_000n +
    BigInt(createdAt.nanoseconds);
  return {
    nextAttemptOrderKey: `integer:${epochNanoseconds.toString()}`,
    paymentId: snapshot.id,
  };
}

function decodeReconcileContinuation(cursor: ReconcileContinuation): {
  createdAt: FirebaseFirestore.Timestamp;
  orderId: string;
} {
  const secondsMatch = /^integer:(-?(?:0|[1-9][0-9]*))$/u.exec(
    cursor.nextAttemptOrderKey
  );
  if (!secondsMatch) {
    throw new Error("Razorpay reconciliation cursor is malformed.");
  }
  const epochNanoseconds = BigInt(secondsMatch[1]);
  let seconds = epochNanoseconds / 1_000_000_000n;
  let nanoseconds = epochNanoseconds % 1_000_000_000n;
  if (nanoseconds < 0) {
    seconds -= 1n;
    nanoseconds += 1_000_000_000n;
  }
  const orderId = cursor.paymentId;
  if (seconds < BigInt(Number.MIN_SAFE_INTEGER) ||
      seconds > BigInt(Number.MAX_SAFE_INTEGER) || orderId.length === 0 ||
      orderId.includes("/") || Buffer.byteLength(orderId, "utf8") > 1500) {
    throw new Error("Razorpay reconciliation cursor is malformed.");
  }
  return {createdAt: new admin.firestore.Timestamp(Number(seconds),
    Number(nanoseconds)), orderId};
}

function sameReconcileContinuation(
  left: ReconcileContinuation | undefined,
  right: ReconcileContinuation | undefined
): boolean {
  return left === undefined && right === undefined ||
    left !== undefined && right !== undefined &&
    left.nextAttemptOrderKey === right.nextAttemptOrderKey &&
    left.paymentId === right.paymentId;
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
  pending,
  runtimeProjectId,
}: {
  db: FirebaseFirestore.Firestore;
  razorpay: Razorpay;
  deps: ReconcileDeps;
  orderId: string;
  pending: RazorpayPendingOrderDocument;
  runtimeProjectId: string;
}): Promise<"fulfilled" | "expired" | "skipped"> {
  const order = await razorpay.orders.fetch(orderId);
  const ownership = resolveRazorpayOrderOwnership({runtimeProjectId, order,
    frozenContexts: [pending.razorpayOwnership]});
  if (ownership.kind !== "owned") return "skipped";
  const razorpayOwnership = assertRazorpayOrderOwnership({
    evidence: ownership.evidence, orderId, runtimeProjectId,
  });
  const razorpayAuthorization = {evidence: ownership.evidence,
    runtimeProjectId};
  const paymentsResult = await razorpay.orders.fetchPayments(orderId);
  const payments = (paymentsResult?.items ?? []) as RazorpayPaymentSnapshot[];
  const captured = payments.find((payment) =>
    capturedStatuses.has(payment.status)
  );

  if (!captured && payments.some((payment) =>
    payment.status === "authorized")) return "skipped";

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

  const result = await fulfillRazorpayPayment({
    db,
    orderId,
    paymentId: captured.id,
    booking,
    razorpayOwnership,
    razorpayAuthorization,
    deps: {
      signUpForEvent: deps.signUpForEvent,
      serverTimestamp: deps.serverTimestamp,
    },
  });
  return result.fulfilled ? "fulfilled" : "skipped";
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
    secrets: [razorpayKeySecret],
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
