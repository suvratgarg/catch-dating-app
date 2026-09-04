/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const duplicateOrganizerFormCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/duplicate_organizer_form_payload.schema.json",
  "title": "DuplicateOrganizerFormCallablePayload",
  "description": "Creates an idempotent new draft copy with entirely new nested identities.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "sourceFormId",
    "requestId",
    "title"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "sourceFormId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "title": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 160
    }
  }
} as const;
