/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const requestClubClaimCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/request_club_claim_response.schema.json",
  "title": "RequestClubClaimCallableResponse",
  "description": "Callable response returned by requestClubClaim after a public organizer claim request is accepted for review.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "requestId",
    "status"
  ],
  "properties": {
    "requestId": {
      "type": "string",
      "minLength": 1
    },
    "status": {
      "type": "string",
      "enum": [
        "pending"
      ]
    }
  }
} as const;
