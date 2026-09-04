/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const requestOrganizerClaimCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/request_organizer_claim_response.schema.json",
  "title": "RequestOrganizerClaimCallableResponse",
  "description": "Callable response returned by requestOrganizerClaim.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "requestId",
    "status"
  ],
  "properties": {
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "status": {
      "type": "string",
      "enum": [
        "pending"
      ]
    }
  }
} as const;
