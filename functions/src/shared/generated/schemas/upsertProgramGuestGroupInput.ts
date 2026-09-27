/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const upsertProgramGuestGroupCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/upsert_program_guest_group_payload.schema.json",
  "title": "UpsertProgramGuestGroupCallablePayload",
  "description": "Create or update an organizer-defined guest group for a program. label and dimension are always supplied; sortOrder preserves the existing value when omitted.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "programId",
    "label",
    "dimension"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "groupId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "label": {
      "type": "string",
      "minLength": 1,
      "maxLength": 140
    },
    "dimension": {
      "type": "string",
      "minLength": 1,
      "maxLength": 60,
      "description": "Grouping axis key. Conventional values per program kind (weddings: side/lineage/relation; corporate: company/delegation/country); other keys are allowed."
    },
    "sortOrder": {
      "type": "integer",
      "minimum": 0,
      "maximum": 10000
    }
  }
} as const;
