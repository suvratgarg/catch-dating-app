/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const actOnEventChatMessageCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/act_on_event_chat_message_payload.schema.json",
  "title": "ActOnEventChatMessageCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "expectedUid",
    "messageId",
    "action",
    "reasonCode",
    "requestId"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expectedUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "messageId": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "action": {
      "type": "string",
      "enum": [
        "report",
        "block",
        "remove"
      ]
    },
    "reasonCode": {
      "anyOf": [
        {
          "type": "string",
          "enum": [
            "harassment",
            "spam",
            "inappropriate",
            "other"
          ]
        },
        {
          "type": "null"
        }
      ]
    },
    "requestId": {
      "type": "string",
      "minLength": 16,
      "maxLength": 128,
      "pattern": "^[A-Za-z0-9_-]+$"
    }
  }
} as const;
