/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by simple event actions that need only an eventId (plus optional inviteCode for invite-gated events).
 */
export interface EventIdCallablePayload {
  eventId: string;
  inviteCode?: string | null;
  inviteLinkId?: string;
}
