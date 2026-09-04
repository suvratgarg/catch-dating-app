/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const revokeParticipantOrganizerDataGrantCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/revoke_participant_organizer_data_grant_response.schema.json",
  "title": "RevokeParticipantOrganizerDataGrantCallableResponse",
  "description": "Revocation outcome and application revision.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "applicationId",
    "revokedAtMillis",
    "revision",
    "replayed"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "applicationId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "revokedAtMillis": {
      "type": "integer",
      "minimum": 0
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "replayed": {
      "type": "boolean"
    }
  }
} as const;
