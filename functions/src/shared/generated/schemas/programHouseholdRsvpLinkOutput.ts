/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programHouseholdRsvpLinkCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/program_household_rsvp_link_response.schema.json",
  "title": "ProgramHouseholdRsvpLinkCallableResponse",
  "description": "A freshly minted household RSVP token with its exclusive expiry. The client composes the share URL.",
  "type": "object",
  "additionalProperties": false,
  "x-callable-aliases": [
    "issueProgramHouseholdRsvpLink"
  ],
  "required": [
    "entityId",
    "token",
    "expiresAtMillis",
    "alreadyApplied"
  ],
  "properties": {
    "entityId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "description": "The household document id."
    },
    "token": {
      "type": "string",
      "minLength": 16,
      "maxLength": 1024
    },
    "expiresAtMillis": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "alreadyApplied": {
      "type": "boolean"
    }
  }
} as const;
