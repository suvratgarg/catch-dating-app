/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface PublicOrganizerTrackingSettingsCallableResponse {
  organizerId: string;
  eventId: string | null;
  enabled: false;
  metaPixelId: null;
  googleMeasurementId: null;
  policyReason:
    | "policyReviewRequired"
    | "sensitiveEvent"
    | "eventClassificationUnavailable";
}
