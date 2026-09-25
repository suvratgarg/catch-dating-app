/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const configureEventOfferPreferencesCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/configure_event_offer_preferences_response.schema.json",
  "title": "ConfigureEventOfferPreferencesCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "preferencesRevision",
    "replayed"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "preferencesRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000000000
    },
    "replayed": {
      "type": "boolean"
    }
  }
} as const;
