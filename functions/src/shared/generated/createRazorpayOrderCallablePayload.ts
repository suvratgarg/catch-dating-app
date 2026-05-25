/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by createRazorpayOrder. Returns a Razorpay order id + amount that the client uses to open the checkout sheet.
 */
export interface CreateRazorpayOrderCallablePayload {
  eventId: string;
  inviteCode?: string | null;
}
