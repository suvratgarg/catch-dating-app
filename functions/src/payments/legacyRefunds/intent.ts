import {createHash} from "node:crypto";
import {validatePaymentDocument} from
  "../../shared/generated/validators/paymentDocument";
import {HttpsError} from "firebase-functions/v2/https";
import type {PaymentDocument} from "../../shared/generated/firestoreAdminTypes";

export type LegacyRefundIntent = NonNullable<
  PaymentDocument["cancellationRefund"]>;
export type LegacyRefundAttempt = LegacyRefundIntent["attempts"][number];

/** The original payment owns the charge and maximum refund liability. */
export function legacyPaymentFingerprint(payment: PaymentDocument): string {
  return createHash("sha256").update(JSON.stringify([
    payment.userId, payment.eventId, payment.paymentId, payment.orderId,
    payment.provider ?? "razorpay", payment.providerPaymentId ?? null,
    payment.amount, payment.amountMinor ?? payment.amount,
    payment.currency, payment.stripeAccountId ?? null,
    payment.applicationFeeAmount ?? 0,
  ])).digest("hex");
}

/** Called only after the cancellation authority is verified in the transaction.
 * A later host cancellation raises the target without changing an in-flight
 * request. Replays preserve the original deadline, attempt and provider key.
 */
export function planLegacyCancellationRefund(input: {
  payment: PaymentDocument;
  reason: LegacyRefundIntent["reason"];
  targetAmountMinor: number;
  nowMillis: number;
}): LegacyRefundIntent {
  const {payment, reason, targetAmountMinor, nowMillis} = input;
  if (!validatePaymentDocument(payment)) unavailable();
  if (!Number.isSafeInteger(nowMillis) || nowMillis <= 0 ||
      !Number.isSafeInteger(targetAmountMinor) || targetAmountMinor < 0 ||
      targetAmountMinor > payment.amount ||
      !eligiblePayment(payment, reason) ||
      (payment.amountMinor ?? payment.amount) !== payment.amount ||
      reason !== "guestCancelled" && targetAmountMinor !== payment.amount) {
    unavailable();
  }
  const old = payment.cancellationRefund;
  if (old) {
    assertLegacyRefundAuthority(payment, old);
    if (reason !== "eventCancelled") {
      if (old.reason !== reason ||
          old.targetAmountMinor !== targetAmountMinor) {
        unavailable();
      }
      return old;
    }
    if (old.targetAmountMinor === targetAmountMinor && old.reason === reason) {
      return old;
    }
    if (old.reason === "bookingFailed" ||
        targetAmountMinor < old.targetAmountMinor) unavailable();
    return {...old, reason, targetAmountMinor,
      state: old.state === "reviewRequired" ? "reviewRequired" :
        old.confirmedAmountMinor >= targetAmountMinor ? "complete" : "pending",
      nextAttemptAtMillis: Math.min(old.nextAttemptAtMillis, nowMillis)};
  }
  // Old refunded records lack reliable partial/full amount evidence.
  const historicalRefund = payment.status === "refunded";
  const provider = payment.provider ?? "razorpay";
  const providerPaymentId = provider === "stripe" ?
    payment.providerPaymentId : payment.paymentId;
  if (!providerPaymentId || !/^[A-Z]{3}$/u.test(payment.currency) ||
      (provider === "razorpay" &&
        !/^pay_[A-Za-z0-9]+$/u.test(providerPaymentId)) ||
      (provider === "stripe" &&
        !/^pi_[A-Za-z0-9]+$/u.test(providerPaymentId))) {
    unavailable();
  }
  return {version: 1, reason,
    state: historicalRefund ? "reviewRequired" :
      targetAmountMinor > 0 ? "pending" : "complete",
    targetAmountMinor, confirmedAmountMinor: 0,
    paymentFingerprint: legacyPaymentFingerprint(payment),
    provider, providerPaymentId, orderId: payment.orderId,
    currency: payment.currency,
    stripeAccountId: payment.stripeAccountId ?? null,
    refundApplicationFee: (payment.applicationFeeAmount ?? 0) > 0,
    requestedAtMillis: nowMillis, nextAttemptAtMillis: nowMillis,
    leaseUntilMillis: 0, attempts: [], lastErrorCode: historicalRefund ?
      "historicalRefundAmountUnknown" : null};
}

export function assertLegacyRefundAuthority(payment: PaymentDocument,
  intent: LegacyRefundIntent): void {
  if (!validatePaymentDocument(payment) ||
      !eligiblePayment(payment, intent.reason) ||
      intent.paymentFingerprint !== legacyPaymentFingerprint(payment) ||
      intent.provider !== (payment.provider ?? "razorpay") ||
      intent.providerPaymentId !== (intent.provider === "stripe" ?
        payment.providerPaymentId : payment.paymentId) ||
      intent.orderId !== payment.orderId ||
      intent.currency !== payment.currency ||
      intent.stripeAccountId !== (payment.stripeAccountId ?? null) ||
      intent.refundApplicationFee !==
        ((payment.applicationFeeAmount ?? 0) > 0) ||
      intent.confirmedAmountMinor > intent.targetAmountMinor ||
      intent.targetAmountMinor > payment.amount ||
      intent.reason !== "guestCancelled" &&
        intent.targetAmountMinor !== payment.amount ||
      intent.attempts.reduce((total, attempt) => total +
        (attempt.state === "failed" ? 0 : attempt.amountMinor), 0) >
          intent.targetAmountMinor ||
      intent.attempts.filter((attempt) =>
        attempt.state === "pending").length > 1 ||
      intent.attempts.filter((attempt) => attempt.state === "processed")
        .reduce((total, attempt) => total + attempt.amountMinor, 0) !==
          intent.confirmedAmountMinor) unavailable();
}

export function legacyRefundAttemptKey(paymentId: string,
  confirmedAmountMinor: number, amountMinor: number): string {
  return `legacy_refund_${createHash("sha256").update(JSON.stringify([
    paymentId, confirmedAmountMinor, amountMinor,
  ])).digest("hex").slice(0, 48)}`;
}

function unavailable(): never {
  throw new HttpsError("failed-precondition",
    "This payment needs refund reconciliation.");
}

function eligiblePayment(payment: PaymentDocument,
  reason: LegacyRefundIntent["reason"]): boolean {
  return reason === "bookingFailed" ? payment.signUpFailed === true &&
    ["refundFailed", "refunded"].includes(payment.status) :
    !payment.signUpFailed && ["completed", "refunded"].includes(payment.status);
}
