/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const updateEventChatAccessCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/update_event_chat_access_payload.schema.json",
  "title": "UpdateEventChatAccessCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "action",
    "expectedRevision",
    "requestId",
    "termsVersion",
    "expectedUid"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "action": {
      "type": "string",
      "enum": [
        "open",
        "close",
        "join",
        "leave",
        "mute",
        "unmute",
        "pause",
        "announcementsOnly",
        "resume",
        "schedule",
        "archive"
      ]
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "termsVersion": {
      "anyOf": [
        {
          "type": "string",
          "enum": [
            "event-chat-v1"
          ]
        },
        {
          "type": "null"
        }
      ]
    },
    "expectedUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "opensAtMillis": {
      "type": "integer",
      "minimum": 0
    },
    "closesAtMillis": {
      "type": "integer",
      "minimum": 0
    }
  }
} as const;
