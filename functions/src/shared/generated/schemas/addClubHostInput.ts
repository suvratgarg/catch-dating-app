/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const addClubHostCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/add_club_host_payload.schema.json",
  "title": "AddClubHostCallablePayload",
  "description": "Callable payload accepted by addClubHost.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "clubId"
  ],
  "oneOf": [
    {
      "required": [
        "uid"
      ]
    },
    {
      "required": [
        "phoneNumber"
      ]
    }
  ],
  "properties": {
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "phoneNumber": {
      "type": "string",
      "minLength": 6,
      "maxLength": 32
    }
  }
} as const;
