/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Frozen native cancellation or failed-booking refund authority. Provider success is distinct from submission; guest refund may be upgraded by host cancellation.
 */
export interface LegacyPaymentRefundIntent {
  version: 1;
  reason: "guestCancelled" | "eventCancelled" | "bookingFailed";
  state: "pending" | "complete" | "reviewRequired";
  targetAmountMinor: number;
  confirmedAmountMinor: number;
  paymentFingerprint: string;
  provider: "razorpay" | "stripe";
  providerPaymentId: string;
  orderId: string;
  currency: string;
  stripeAccountId: string | null;
  refundApplicationFee: boolean;
  requestedAtMillis: number;
  nextAttemptAtMillis: number;
  leaseUntilMillis: number;
  /**
   * @maxItems 2
   */
  attempts: {
    amountMinor: number;
    idempotencyKey: string;
    providerRefundId: string | null;
    state: "pending" | "processed" | "failed";
    startedAtMillis: number;
  }[];
  lastErrorCode: string | null;
}
