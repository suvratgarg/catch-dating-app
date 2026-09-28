/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const setEventPublicationCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/set_event_publication_payload.schema.json",
  "title": "SetEventPublicationCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "requestId",
    "eventId",
    "expectedSetupRevision",
    "publicationState"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "requestId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{7,127}$"
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expectedSetupRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 2147483646
    },
    "publicationState": {
      "type": "string",
      "enum": [
        "private",
        "published"
      ]
    }
  }
} as const;
