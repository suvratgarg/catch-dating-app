/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by setCrossPathsEventConsent.
 */
export interface SetCrossPathsEventConsentCallablePayload {
  eventId: string;
  enabled: boolean;
  termsVersion: number;
  source: "booking_success" | "event_detail" | "settings";
}
