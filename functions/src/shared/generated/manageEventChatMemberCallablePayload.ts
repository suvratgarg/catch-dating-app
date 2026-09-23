/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Organizer manager removes, bans or explicitly reinstates a room member. Reinstatement never joins on the participant's behalf.
 */
export interface ManageEventChatMemberCallablePayload {
  eventId: string;
  targetUid: string;
  action: "remove" | "ban" | "reinstate";
  expectedRevision: number;
  requestId: string;
  expectedUid: string;
}
