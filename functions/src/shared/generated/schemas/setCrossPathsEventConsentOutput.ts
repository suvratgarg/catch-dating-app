/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const setCrossPathsEventConsentCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/set_cross_paths_event_consent_response.schema.json",
  "title": "SetCrossPathsEventConsentCallableResponse",
  "description": "Sanitized response returned by setCrossPathsEventConsent.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "enabled",
    "termsVersion"
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
    }
  }
} as const;
