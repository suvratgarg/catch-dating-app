/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const sendEventChatMessageCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/send_event_chat_message_payload.schema.json",
  "title": "SendEventChatMessageCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "requestId",
    "text",
    "replyToMessageId",
    "expectedUid"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "text": {
      "type": "string",
      "minLength": 1,
      "maxLength": 2000
    },
    "replyToMessageId": {
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
    "expectedUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
