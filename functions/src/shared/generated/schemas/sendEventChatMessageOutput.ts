/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const sendEventChatMessageCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/send_event_chat_message_response.schema.json",
  "title": "SendEventChatMessageCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "messageId",
    "sequence",
    "replayed"
  ],
  "properties": {
    "messageId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "sequence": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "replayed": {
      "type": "boolean"
    }
  }
} as const;
