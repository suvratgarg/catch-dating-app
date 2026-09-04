/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const deleteClubCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/delete_club_payload.schema.json",
  "title": "DeleteClubCallablePayload",
  "description": "Callable payload accepted by deleteClub.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "clubId"
  ],
  "properties": {
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
