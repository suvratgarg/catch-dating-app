/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listOrganizerProgramsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/list_organizer_programs_payload.schema.json",
  "title": "ListOrganizerProgramsCallablePayload",
  "description": "Manager-scoped listing of an organizer's private programs.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "limit": {
      "type": "integer",
      "minimum": 1,
      "maximum": 50
    },
    "cursor": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "description": "Optional last program ID from nextCursor. Server verifies current organizer scope and continues after its canonical snapshot."
    },
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "description": "Optional exact program ID for bounded saved-program confirmation. Organizer authority and document scope are rechecked; cannot be combined with cursor."
    }
  },
  "not": {
    "required": [
      "cursor",
      "programId"
    ]
  }
} as const;
