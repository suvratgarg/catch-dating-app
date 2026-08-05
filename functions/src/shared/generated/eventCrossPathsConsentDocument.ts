/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private per-user Cross Paths consent edge stored at eventCrossPathsConsents/{eventId_uid} and written only by setCrossPathsEventConsent.
 */
export interface EventCrossPathsConsentDocument {
  eventId: string;
  uid: string;
  enabled: boolean;
  termsVersion: number;
  consentedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  revokedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  source: "booking_success" | "event_detail" | "settings";
}
