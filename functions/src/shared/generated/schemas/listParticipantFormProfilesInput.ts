/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listParticipantFormProfilesCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/list_participant_form_profiles_payload.schema.json",
  "title": "ListParticipantFormProfilesCallablePayload",
  "description": "List only the verified participant’s active form profile proposals and private cards.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "cursor",
    "limit"
  ],
  "properties": {
    "cursor": {
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
    "limit": {
      "type": "integer",
      "minimum": 1,
      "maximum": 30
    }
  }
} as const;
