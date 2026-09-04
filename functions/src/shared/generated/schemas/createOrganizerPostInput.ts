/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const createOrganizerPostCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/create_organizer_post_payload.schema.json",
  "title": "CreateOrganizerPostCallablePayload",
  "description": "Callable payload accepted by createOrganizerPost.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "requestId",
    "text"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "text": {
      "type": "string",
      "minLength": 1,
      "maxLength": 500
    },
    "photoPath": {
      "type": "string",
      "minLength": 1,
      "maxLength": 500
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
