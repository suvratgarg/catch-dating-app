/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const setEventChatReactionCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/set_event_chat_reaction_payload.schema.json",
  "title": "SetEventChatReactionCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "messageId",
    "requestId",
    "reaction",
    "expectedRevision"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "messageId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "reaction": {
      "anyOf": [
        {
          "type": "string",
          "enum": [
            "like",
            "love",
            "laugh",
            "wow",
            "sad",
            "thanks"
          ]
        },
        {
          "type": "null"
        }
      ]
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    }
  }
} as const;
