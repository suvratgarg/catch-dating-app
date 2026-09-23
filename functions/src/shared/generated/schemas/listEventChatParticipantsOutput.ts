/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listEventChatParticipantsCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/list_event_chat_participants_response.schema.json",
  "title": "ListEventChatParticipantsCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "items",
    "nextCursor"
  ],
  "properties": {
    "items": {
      "type": "array",
      "maxItems": 10,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "uid",
          "displayName",
          "role"
        ],
        "properties": {
          "uid": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "displayName": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
          },
          "role": {
            "type": "string",
            "enum": [
              "host",
              "attendee"
            ]
          }
        }
      }
    },
    "nextCursor": {
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
    }
  }
} as const;
