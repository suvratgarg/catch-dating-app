/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable response returned by createRazorpayOrder.
 */
export interface RazorpayOrderCallableResponse {
  orderId: string;
  amount: number;
  currency: string;
  /**
   * Public Razorpay checkout key id from the same server environment that created the order. This is not the secret key.
   */
  keyId: string;
}
