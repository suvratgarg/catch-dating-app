/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listProgramStaffCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/list_program_staff_payload.schema.json",
  "title": "ListProgramStaffCallablePayload",
  "description": "Manager-only staff inventory in stable staff-identity order.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "programId"
  ],
  "properties": {
    "programId": {
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
      "maxLength": 180,
      "description": "Staff UID continuation returned by the preceding page. Ordering survives renewal and revocation.",
      "minLength": 1,
      "pattern": "^[^/]+$"
    }
  }
} as const;
