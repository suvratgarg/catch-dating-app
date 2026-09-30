/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const unarchiveProgramCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/unarchive_program_response.schema.json",
  "title": "UnarchiveProgramCallableResponse",
  "description": "Unarchive acknowledgement: committed program revision plus the status restored from the pre-archive record.",
  "type": "object",
  "additionalProperties": false,
  "x-callable-aliases": [
    "unarchiveProgram"
  ],
  "required": [
    "entityId",
    "revision",
    "alreadyApplied",
    "restoredStatus"
  ],
  "properties": {
    "entityId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "alreadyApplied": {
      "type": "boolean",
      "description": "True when an exact clientOperationId replay returned the original result."
    },
    "restoredStatus": {
      "type": "string",
      "enum": [
        "draft",
        "active",
        "completed",
        "archived"
      ]
    }
  }
} as const;
