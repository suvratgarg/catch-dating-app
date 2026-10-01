/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerTrackingSettingsCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/organizer_tracking_settings_response.schema.json",
  "title": "OrganizerTrackingSettingsCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "revision",
    "metaPixelId",
    "googleMeasurementId",
    "enabled",
    "publicationAllowed",
    "policyReason",
    "canEdit",
    "editBlockedReason"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$"
    },
    "revision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "metaPixelId": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^[0-9]{5,20}$"
    },
    "googleMeasurementId": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^G-[A-Z0-9]{4,20}$"
    },
    "enabled": {
      "type": "boolean",
      "const": false
    },
    "publicationAllowed": {
      "type": "boolean",
      "const": false
    },
    "policyReason": {
      "const": "policyReviewRequired",
      "type": "string"
    },
    "canEdit": {
      "type": "boolean"
    },
    "editBlockedReason": {
      "type": "string",
      "enum": [
        "none",
        "unclaimed"
      ]
    }
  }
} as const;
