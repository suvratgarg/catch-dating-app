/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const setCrossPathsEventConsentCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/set_cross_paths_event_consent_payload.schema.json",
  "title": "SetCrossPathsEventConsentCallablePayload",
  "description": "Callable payload accepted by setCrossPathsEventConsent.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "enabled",
    "termsVersion",
    "source"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "enabled": {
      "type": "boolean"
    },
    "termsVersion": {
      "type": "integer",
      "minimum": 1
    },
    "source": {
      "type": "string",
      "enum": [
        "booking_success",
        "event_detail",
        "settings"
      ]
    }
  }
} as const;
