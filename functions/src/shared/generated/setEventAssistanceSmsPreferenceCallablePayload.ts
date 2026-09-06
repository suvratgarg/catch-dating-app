/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface SetEventAssistanceSmsPreferenceCallablePayload {
  eventId: string;
  attendeeId: string;
  requestId: string;
  expectedRevision: null | number;
  decision:
    | {
        kind: "grant";
        copyVersion: "catch-event-service-sms-v1";
      }
    | {
        kind: "revoke";
      };
}
