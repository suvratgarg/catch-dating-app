/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const createClubPostCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/create_club_post_payload.schema.json",
  "title": "CreateClubPostCallablePayload",
  "description": "Callable payload accepted by createClubPost.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "clubId",
    "text"
  ],
  "properties": {
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "text": {
      "type": "string",
      "minLength": 1,
      "maxLength": 500
    },
    "photoPath": {
      "type": "string",
      "minLength": 1,
      "maxLength": 500
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
