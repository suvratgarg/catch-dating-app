/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface SendEventChatMessageCallablePayload {
  eventId: string;
  requestId: string;
  text: string;
  replyToMessageId: string | null;
  expectedUid: string;
  kind?: "text" | "announcement";
}
