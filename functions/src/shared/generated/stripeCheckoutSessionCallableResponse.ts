/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable response returned by createStripeCheckoutSession.
 */
export interface StripeCheckoutSessionCallableResponse {
  sessionId: string;
  paymentId: string;
  amountMinor: number;
  currency: string;
  checkoutUrl: string;
  provider: "stripe";
}
