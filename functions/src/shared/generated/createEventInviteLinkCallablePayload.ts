/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by createEventInviteLink. Hosts use this to create named share links such as Instagram bio, WhatsApp alumni, or venue partner.
 */
export interface CreateEventInviteLinkCallablePayload {
  eventId: string;
  label: string;
  source?: string | null;
}
