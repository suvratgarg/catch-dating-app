/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventAssistanceSmsPreferenceCallableResponse {
  outcome: "read" | "applied" | "replayed" | "conflict";
  view: {
    eventId: string;
    attendeeId: string;
    serverTime: number;
    revision: null | number;
    preference: "notSet" | "enabled" | "disabled" | "expired";
    canEnable: boolean;
    availability:
      | "ready"
      | "senderUnavailable"
      | "eventClosed"
      | "notAdmitted"
      | "verifyPhone";
    phoneLastFour: null | string;
    expiresAt: null | number;
    consent: {
      version: "catch-event-service-sms-v1";
      text: string;
    };
  };
}
