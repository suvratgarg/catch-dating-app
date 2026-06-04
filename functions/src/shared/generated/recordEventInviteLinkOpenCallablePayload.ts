/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by recordEventInviteLinkOpen. It increments a live open counter and returns whether attribution can be attached to downstream booking actions.
 */
export interface RecordEventInviteLinkOpenCallablePayload {
  eventId: string;
  inviteLinkId: string;
}
