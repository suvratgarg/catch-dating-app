/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const setEventChatTypingCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/set_event_chat_typing_payload.schema.json",
  "title": "SetEventChatTypingCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "isTyping",
    "expectedRevision",
    "expectedUid"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "isTyping": {
      "type": "boolean"
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "expectedUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
