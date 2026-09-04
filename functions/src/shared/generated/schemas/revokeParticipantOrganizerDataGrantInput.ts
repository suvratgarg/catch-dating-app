/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const revokeParticipantOrganizerDataGrantCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/revoke_participant_organizer_data_grant_payload.schema.json",
  "title": "RevokeParticipantOrganizerDataGrantCallablePayload",
  "description": "Revokes the authenticated participant's organizer access grant without deleting the platform audit snapshot.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "applicationId",
    "expectedRevision"
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
    "expectedRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    }
  }
} as const;
