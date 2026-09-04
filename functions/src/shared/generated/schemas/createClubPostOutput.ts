/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const createClubPostCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/create_club_post_response.schema.json",
  "title": "CreateClubPostCallableResponse",
  "description": "Callable response returned by createClubPost.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "postId",
    "remainingWeeklyQuota"
  ],
  "properties": {
    "postId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "remainingWeeklyQuota": {
      "type": "integer",
      "minimum": 0,
      "maximum": 3
    }
  }
} as const;
