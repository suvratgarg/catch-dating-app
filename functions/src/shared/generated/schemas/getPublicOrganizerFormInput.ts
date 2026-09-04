/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getPublicOrganizerFormCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/get_public_organizer_form_payload.schema.json",
  "title": "GetPublicOrganizerFormCallablePayload",
  "description": "Resolves one bounded public form projection.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "publicFormId",
    "sourceToken"
  ],
  "properties": {
    "publicFormId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{20,80}$"
    },
    "sourceToken": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^[A-Za-z0-9_-]{20,160}$"
    }
  }
} as const;
