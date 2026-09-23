/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listEventChatParticipantsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/list_event_chat_participants_payload.schema.json",
  "title": "ListEventChatParticipantsCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "expectedUid",
    "cursor",
    "limit"
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
    "cursor": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "eventId",
            "accountUid",
            "after"
          ],
          "properties": {
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "accountUid": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "after": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            }
          }
        },
        {
          "type": "null"
        }
      ]
    },
    "limit": {
      "type": "integer",
      "minimum": 1,
      "maximum": 10
    }
  }
} as const;
