/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const issueProgramHouseholdRsvpLinkCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/issue_program_household_rsvp_link_payload.schema.json",
  "title": "IssueProgramHouseholdRsvpLinkCallablePayload",
  "description": "Mint a signed RSVP link token for one household. The token carries only ids and an exclusive expiry; default expiry is the program end.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "programId",
    "householdId"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "householdId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expiresAtMillis": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991,
      "description": "Exclusive token expiry in epoch milliseconds; defaults to the program's endsAt."
    }
  }
} as const;
