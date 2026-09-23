/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const upsertProgramGuestCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/upsert_program_guest_payload.schema.json",
  "title": "UpsertProgramGuestCallablePayload",
  "description": "Create or update one program guest. guestId absent creates; expectedRevision fences updates. A shared phone never merges guests.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "programId",
    "displayName"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "guestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "displayName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 140
    },
    "householdId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "phoneE164": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 20
    },
    "email": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 320
    },
    "externalReference": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 180
    },
    "rsvpStatus": {
      "type": "string",
      "enum": [
        "pending",
        "attending",
        "declined",
        "maybe"
      ]
    }
  }
} as const;
