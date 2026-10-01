/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const publicOrganizerTrackingSettingsCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/public_organizer_tracking_settings_response.schema.json",
  "title": "PublicOrganizerTrackingSettingsCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "eventId",
    "enabled",
    "metaPixelId",
    "googleMeasurementId",
    "policyReason"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$"
    },
    "eventId": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$"
    },
    "enabled": {
      "type": "boolean",
      "const": false
    },
    "metaPixelId": {
      "type": "null"
    },
    "googleMeasurementId": {
      "type": "null"
    },
    "policyReason": {
      "type": "string",
      "enum": [
        "policyReviewRequired",
        "sensitiveEvent",
        "eventClassificationUnavailable"
      ]
    }
  }
} as const;
