/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface SetEventWhatsappPreferenceCallablePayload {
  eventId: string;
  attendeeId: string;
  requestId: string;
  expectedRevision: null | number;
  decision:
    | {
        kind: "grant";
        copyVersion: "catch-event-service-whatsapp-v1";
        senderHash: string;
        stopRecordHash: null | string;
      }
    | {
        kind: "revoke";
      };
  senderId: string;
}
