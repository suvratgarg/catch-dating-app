import type {PaymentDocument} from "../../shared/generated/firestoreAdminTypes";
import {LegacyRefundReviewRequired} from "./errors";
import {requireDoc} from "../../shared/validation";
import {assertLegacyRefundAuthority, legacyRefundAttemptKey,
  type LegacyRefundAttempt, type LegacyRefundIntent} from "./intent";

export interface LegacyRefundProvider {
  verifyPayment(payment: PaymentDocument, intent: LegacyRefundIntent):
    Promise<void>;
  createRefund(intent: LegacyRefundIntent, attempt: LegacyRefundAttempt):
    Promise<LegacyRefundObservation>;
  fetchRefund(intent: LegacyRefundIntent, attempt: LegacyRefundAttempt):
    Promise<LegacyRefundObservation>;
}
export interface LegacyRefundObservation {
  id: string;
  paymentId: string;
  amountMinor: number;
  currency: string;
  state: "pending" | "processed" | "failed";
}

/** A durable, provider-specific cancellation refund. A lease serializes local
 * work; the frozen provider idempotency key survives an uncertain POST or a
 * lost Firestore acknowledgement. Only observed success reduces liability.
 */
export async function processLegacyCancellationRefund(input: {
  db: FirebaseFirestore.Firestore; paymentId: string;
  provider: LegacyRefundProvider; clock?: () => number;
}): Promise<void> {
  const {db, paymentId, provider} = input;
  const clock = input.clock ?? Date.now;
  const ref = db.collection("payments").doc(paymentId);
  const claim = await db.runTransaction(async (tx) => {
    const payment = requireDoc<PaymentDocument>(await tx.get(ref),
      "PaymentDocument");
    const old = payment.cancellationRefund;
    if (!old || old.state !== "pending") return null;
    assertLegacyRefundAuthority(payment, old);
    const now = clock();
    if (old.nextAttemptAtMillis > now || old.leaseUntilMillis > now) {
      return null;
    }
    const attempts = [...old.attempts];
    let index = attempts.findIndex((attempt) => attempt.state === "pending");
    if (index < 0) {
      const amountMinor = old.targetAmountMinor - old.confirmedAmountMinor;
      if (amountMinor <= 0 || attempts.length >= 2) {
        tx.update(ref, {cancellationRefund: {...old, state: "reviewRequired",
          lastErrorCode: "inconsistentRefundIntent"}});
        return null;
      }
      index = attempts.length;
      attempts.push({amountMinor, state: "pending", providerRefundId: null,
        idempotencyKey: legacyRefundAttemptKey(paymentId,
          old.confirmedAmountMinor, amountMinor), startedAtMillis: now});
    }
    const attempt = attempts[index];
    // Stripe can prune idempotency keys after 24 hours. An unresolved old POST
    // requires reconciliation; never create a second refund after that window.
    if (old.provider === "stripe" && !attempt.providerRefundId &&
        now - attempt.startedAtMillis >= 23 * 3600_000) {
      tx.update(ref, {cancellationRefund: {...old, state: "reviewRequired",
        leaseUntilMillis: 0, lastErrorCode: "refundOutcomeUnknown"}});
      return null;
    }
    const intent = {...old, attempts, leaseUntilMillis: now + 180_000};
    tx.update(ref, {cancellationRefund: intent});
    return {payment, intent, index};
  });
  if (!claim) return;
  try {
    await provider.verifyPayment(claim.payment, claim.intent);
    const attempt = claim.intent.attempts[claim.index];
    const observation = attempt.providerRefundId ?
      await provider.fetchRefund(claim.intent, attempt) :
      await provider.createRefund(claim.intent, attempt);
    if (observation.paymentId !== claim.intent.providerPaymentId ||
        observation.amountMinor !== attempt.amountMinor ||
        observation.currency !== claim.intent.currency || !observation.id ||
        !["pending", "processed", "failed"].includes(observation.state) ||
        attempt.providerRefundId &&
          observation.id !== attempt.providerRefundId) {
      throw new LegacyRefundReviewRequired(
        "Refund differs from its frozen payment authority.");
    }
    await db.runTransaction(async (tx) => {
      const payment = requireDoc<PaymentDocument>(await tx.get(ref),
        "PaymentDocument");
      const current = payment.cancellationRefund;
      if (!current ||
          current.leaseUntilMillis !== claim.intent.leaseUntilMillis) {
        return;
      }
      assertLegacyRefundAuthority(payment, current);
      if (current.attempts[claim.index]?.idempotencyKey !==
          attempt.idempotencyKey || current.state !== "pending") return;
      const attempts = [...current.attempts];
      attempts[claim.index] = {...attempt,
        providerRefundId: observation.id, state: observation.state};
      const confirmedAmountMinor = attempts
        .filter((value) => value.state === "processed")
        .reduce((total, value) => total + value.amountMinor, 0);
      tx.update(ref, {cancellationRefund: {...current, attempts,
        confirmedAmountMinor, leaseUntilMillis: 0,
        nextAttemptAtMillis: clock() +
          (observation.state === "pending" ? 120_000 : 0),
        state: observation.state === "failed" ? "reviewRequired" :
          confirmedAmountMinor === current.targetAmountMinor ?
            "complete" : "pending",
        lastErrorCode: observation.state === "failed" ? "refundFailed" : null},
      ...(confirmedAmountMinor === payment.amount ?
        {status: "refunded"} : {})});
    });
  } catch (error) {
    await db.runTransaction(async (tx) => {
      const payment = requireDoc<PaymentDocument>(await tx.get(ref),
        "PaymentDocument");
      const current = payment.cancellationRefund;
      if (current?.leaseUntilMillis === claim.intent.leaseUntilMillis) {
        tx.update(ref, {cancellationRefund: {...current, leaseUntilMillis: 0,
          nextAttemptAtMillis: clock() + 120_000,
          state: error instanceof LegacyRefundReviewRequired ?
            "reviewRequired" : current.state,
          lastErrorCode: error instanceof LegacyRefundReviewRequired ?
            "providerAuthorityMismatch" : "refundNeedsRetry"}});
      }
    });
    throw error;
  }
}
