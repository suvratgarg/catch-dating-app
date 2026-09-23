/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Owner-only payment status or signed checkout callback; success still requires server capture verification.
 */
export interface GetOrganizerFormPaymentCallablePayload {
  paymentId: string;
  callback: {
    paymentId: string;
    signature: string;
  } | null;
}
