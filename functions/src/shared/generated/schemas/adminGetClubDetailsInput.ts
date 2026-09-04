/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminGetClubDetailsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_get_club_details_payload.schema.json",
  "title": "AdminGetClubDetailsCallablePayload",
  "description": "Callable payload accepted by adminGetClubDetails.",
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
