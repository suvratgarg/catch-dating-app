/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface ActOnEventChatMessageCallablePayload {
  eventId: string;
  expectedUid: string;
  messageId: string;
  action: "report" | "block" | "remove";
  reasonCode: ("harassment" | "spam" | "inappropriate" | "other") | null;
  requestId: string;
}
