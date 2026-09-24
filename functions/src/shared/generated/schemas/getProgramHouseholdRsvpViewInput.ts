/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getProgramHouseholdRsvpViewCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/get_program_household_rsvp_view_payload.schema.json",
  "title": "GetProgramHouseholdRsvpViewCallablePayload",
  "description": "Token-authenticated read of one household's RSVP surface. The signed token is the credential; no session is required.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "token"
  ],
  "properties": {
    "token": {
      "type": "string",
      "minLength": 16,
      "maxLength": 1024
    }
  }
} as const;
