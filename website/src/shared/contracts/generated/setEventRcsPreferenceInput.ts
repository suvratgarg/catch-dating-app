/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface SetEventRcsPreferenceCallablePayload {
  eventId: string;
  attendeeId: string;
  senderId: string;
  requestId: string;
  expectedRevision: null | number;
  decision:
    | {
        kind: "grant";
        copyVersion: "catch-event-service-rcs-v1";
        reviewHash: string;
      }
    | {
        kind: "revoke";
      };
}
