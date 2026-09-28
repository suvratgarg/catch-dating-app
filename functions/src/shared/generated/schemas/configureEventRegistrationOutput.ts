/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const configureEventRegistrationCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/configure_event_registration_response.schema.json",
  "title": "ConfigureEventRegistrationCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "registrationRevision",
    "mode",
    "replayed"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "registrationRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "mode": {
      "enum": [
        "closed",
        "free",
        "paid"
      ]
    },
    "replayed": {
      "type": "boolean"
    }
  }
} as const;
