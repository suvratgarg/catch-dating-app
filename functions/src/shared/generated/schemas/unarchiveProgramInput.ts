/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const unarchiveProgramCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/unarchive_program_payload.schema.json",
  "title": "UnarchiveProgramCallablePayload",
  "description": "Restore an archived program to its pre-archive status. Only valid while the grace window is still open; expectedRevision fences concurrent edits.",
  "type": "object",
  "additionalProperties": false,
  "x-callable-aliases": [
    "unarchiveProgram"
  ],
  "required": [
    "programId",
    "expectedRevision"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    }
  }
} as const;
