/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/generate_schema_contracts.mjs

/**
 * Callable payload accepted by verifyRazorpayPayment.
 */
export interface VerifyRazorpayPaymentCallablePayload {
  paymentId: string;
  orderId: string;
  signature: string;
}
