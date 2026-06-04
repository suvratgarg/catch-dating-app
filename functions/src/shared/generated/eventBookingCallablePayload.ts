/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by signUpForFreeEvent. Same shape as EventIdCallablePayload but distinct so the booking flow can diverge without breaking the generic event-id callables.
 */
export interface EventBookingCallablePayload {
  eventId: string;
  inviteCode?: string | null;
  inviteLinkId?: string;
}
