/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by createStripeCheckoutSession. The server derives amount, currency, host account, and booking metadata from Firestore.
 */
export interface CreateStripeCheckoutSessionCallablePayload {
  eventId: string;
  inviteCode?: string | null;
}
