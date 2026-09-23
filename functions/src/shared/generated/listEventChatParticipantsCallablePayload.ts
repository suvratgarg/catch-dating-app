/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface ListEventChatParticipantsCallablePayload {
  eventId: string;
  expectedUid: string;
  cursor: {
    eventId: string;
    accountUid: string;
    after: string;
  } | null;
  limit: number;
}
