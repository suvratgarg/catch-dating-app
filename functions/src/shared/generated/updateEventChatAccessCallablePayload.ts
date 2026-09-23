/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface UpdateEventChatAccessCallablePayload {
  eventId: string;
  action: "open" | "close" | "join" | "leave";
  expectedRevision: number;
  requestId: string;
  termsVersion: "event-chat-v1" | null;
  expectedUid: string;
}
