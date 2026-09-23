/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const claimParticipantFormProfileCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/claim_participant_form_profile_response.schema.json",
  "title": "ClaimParticipantFormProfileCallableResponse",
  "description": "Private claim result. No public or room sharing is inferred.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "profileRevision",
    "organizerCardId",
    "claimedAtMillis",
    "replayed"
  ],
  "properties": {
    "profileRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "organizerCardId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    },
    "claimedAtMillis": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "replayed": {
      "type": "boolean"
    }
  }
} as const;
