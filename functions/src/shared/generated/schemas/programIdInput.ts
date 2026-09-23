/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programIdCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/program_id_payload.schema.json",
  "title": "ProgramIdCallablePayload",
  "description": "Program-scoped read payload shared by simple program callables.",
  "type": "object",
  "additionalProperties": false,
  "x-callable-aliases": [
    "getOrganizerProgram",
    "getProgramWorkAccess",
    "listProgramStaff",
    "listProgramHouseholds"
  ],
  "required": [
    "programId"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
