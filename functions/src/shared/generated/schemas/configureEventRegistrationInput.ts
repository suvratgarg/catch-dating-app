/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const configureEventRegistrationCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/configure_event_registration_payload.schema.json",
  "title": "ConfigureEventRegistrationCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "eventId",
    "requestId",
    "expectedRegistrationRevision",
    "mode"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "requestId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{7,119}$"
    },
    "expectedRegistrationRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "mode": {
      "enum": [
        "closed",
        "free",
        "paid"
      ]
    }
  }
} as const;
