/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listParticipantMessagingPreferencesCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/list_participant_messaging_preferences_payload.schema.json",
  "title": "ListParticipantMessagingPreferencesCallablePayload",
  "description": "Read only the signed-in participant’s independent Catch and organizer WhatsApp permissions.",
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
