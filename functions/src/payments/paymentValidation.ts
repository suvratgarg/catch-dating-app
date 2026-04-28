import {HttpsError} from "firebase-functions/v2/https";
import {PaymentStatus, RunDoc} from "../shared/firestore";
import {razorpayCurrency} from "./razorpay";

interface RazorpayOrderNotes {
  [key: string]: string | number | null;
}

export interface RazorpayOrderSnapshot {
  id: string;
  amount: number | string;
  currency: string;
  amount_paid: number | string;
  amount_due: number | string;
  notes?: RazorpayOrderNotes | null;
}

export interface RazorpayPaymentSnapshot {
  id: string;
  order_id: string;
  amount: number | string;
  currency: string;
  status: string;
  refund_status?: string | null;
  amount_refunded?: number;
}

export interface VerifiedPaymentBooking {
  runId: string;
  userId: string;
  amountInPaise: number;
  currency: string;
}

export interface PaymentRecordInput extends VerifiedPaymentBooking {
  orderId: string;
  paymentId: string;
  status: PaymentStatus;
  signUpFailed?: boolean;
}

const successfulPaymentStatuses = new Set(["authorized", "captured"]);

/**
 * Builds the trusted Razorpay order payload for a paid run.
 * @param {object} params Input parameters.
 * @param {string} params.runId Run id being booked.
 * @param {RunDoc} params.run Trusted Firestore run snapshot.
 * @param {string} params.userId Authenticated user id.
 * @param {string|number} params.receiptToken Receipt uniqueness token.
 * @return {object} Razorpay order creation payload.
 */
export function buildOrderCreatePayload({
  runId,
  run,
  userId,
  receiptToken,
}: {
  runId: string;
  run: RunDoc;
  userId: string;
  receiptToken: string | number;
}) {
  const amountInPaise = parsePositiveAmount(run.priceInPaise, "Run price");

  return {
    amount: amountInPaise,
    currency: razorpayCurrency,
    receipt: `run_${runId}_${receiptToken}`,
    notes: {
      runId,
      userId,
    },
  };
}

/**
 * Verifies Razorpay order/payment snapshots and returns booking truth.
 * @param {object} params Input parameters.
 * @param {RazorpayOrderSnapshot} params.order Razorpay order snapshot.
 * @param {RazorpayPaymentSnapshot} params.payment Razorpay payment snapshot.
 * @param {string} params.expectedUserId Authenticated user id.
 * @return {VerifiedPaymentBooking} Trusted booking details.
 */
export function verifyPaidRunBooking({
  order,
  payment,
  expectedUserId,
}: {
  order: RazorpayOrderSnapshot;
  payment: RazorpayPaymentSnapshot;
  expectedUserId: string;
}): VerifiedPaymentBooking {
  const orderAmount = parsePositiveAmount(order.amount, "Order amount");
  const orderAmountPaid = parseNonNegativeAmount(
    order.amount_paid,
    "Order paid amount"
  );
  const orderAmountDue = parseNonNegativeAmount(
    order.amount_due,
    "Order due amount"
  );

  if (order.currency !== razorpayCurrency) {
    throw new HttpsError(
      "invalid-argument",
      `Unsupported order currency: ${order.currency}.`
    );
  }

  if (orderAmountPaid < orderAmount || orderAmountDue !== 0) {
    throw new HttpsError(
      "failed-precondition",
      "Order has not been fully paid."
    );
  }

  if (payment.order_id !== order.id) {
    throw new HttpsError(
      "invalid-argument",
      "Payment does not belong to this order."
    );
  }

  const paymentAmount = parsePositiveAmount(payment.amount, "Payment amount");
  if (paymentAmount !== orderAmount) {
    throw new HttpsError(
      "invalid-argument",
      "Payment amount does not match the order amount."
    );
  }

  if (payment.currency !== order.currency) {
    throw new HttpsError(
      "invalid-argument",
      "Payment currency does not match the order currency."
    );
  }

  if (!successfulPaymentStatuses.has(payment.status)) {
    throw new HttpsError(
      "failed-precondition",
      "Payment is not in a successful state."
    );
  }

  if (hasRefund(payment)) {
    throw new HttpsError(
      "failed-precondition",
      "Refunded payments cannot be used for booking."
    );
  }

  const runId = getRequiredNote(order.notes, "runId");
  const userId = getRequiredNote(order.notes, "userId");

  if (userId !== expectedUserId) {
    throw new HttpsError(
      "permission-denied",
      "This order does not belong to the signed-in user."
    );
  }

  return {
    runId,
    userId,
    amountInPaise: orderAmount,
    currency: order.currency,
  };
}

/**
 * Builds the Firestore payment document body.
 * @param {PaymentRecordInput} input Payment record input.
 * @return {object} Firestore payment record.
 */
export function buildPaymentRecord({
  userId,
  orderId,
  paymentId,
  runId,
  amountInPaise,
  currency,
  status,
  signUpFailed = false,
}: PaymentRecordInput) {
  return {
    userId,
    orderId,
    paymentId,
    runId,
    amount: amountInPaise,
    currency,
    status,
    signUpFailed,
  };
}

/**
 * Reads a required Razorpay order note as a non-empty string.
 * @param {RazorpayOrderNotes|null|undefined} notes Razorpay order notes.
 * @param {string} key Required note key.
 * @return {string} Required note value.
 */
function getRequiredNote(
  notes: RazorpayOrderNotes | null | undefined,
  key: string
): string {
  const rawValue = notes?.[key];
  if (typeof rawValue !== "string" || rawValue.trim().length === 0) {
    throw new HttpsError(
      "invalid-argument",
      `Order is missing required booking metadata: ${key}.`
    );
  }

  return rawValue;
}

/**
 * Parses a positive integer payment amount.
 * @param {number|string} value Raw amount value.
 * @param {string} label Human-readable field label.
 * @return {number} Parsed amount.
 */
function parsePositiveAmount(value: number | string, label: string): number {
  const amount = Number(value);
  if (!Number.isInteger(amount) || amount <= 0) {
    throw new HttpsError(
      "invalid-argument",
      `${label} must be a positive integer.`
    );
  }

  return amount;
}

/**
 * Parses a non-negative integer payment amount.
 * @param {number|string} value Raw amount value.
 * @param {string} label Human-readable field label.
 * @return {number} Parsed amount.
 */
function parseNonNegativeAmount(
  value: number | string,
  label: string
): number {
  const amount = Number(value);
  if (!Number.isInteger(amount) || amount < 0) {
    throw new HttpsError(
      "invalid-argument",
      `${label} must be a non-negative integer.`
    );
  }

  return amount;
}

/**
 * Returns whether Razorpay reports any refund state for the payment.
 * @param {RazorpayPaymentSnapshot} payment Razorpay payment snapshot.
 * @return {boolean} Whether the payment has refund evidence.
 */
function hasRefund(payment: RazorpayPaymentSnapshot): boolean {
  const refundedAmount = payment.amount_refunded ?? 0;
  const refundStatus = payment.refund_status;

  return refundedAmount > 0 ||
    (refundStatus !== undefined &&
      refundStatus !== null &&
      refundStatus !== "null");
}
