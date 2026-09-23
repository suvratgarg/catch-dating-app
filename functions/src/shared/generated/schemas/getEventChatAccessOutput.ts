/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getEventChatAccessCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/get_event_chat_access_response.schema.json",
  "title": "GetEventChatAccessCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "organizerId",
    "title",
    "role",
    "room",
    "membership",
    "canManage",
    "canJoin",
    "canReadMessages",
    "profileClaimRequired",
    "termsVersion"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "title": {
      "type": "string",
      "maxLength": 200
    },
    "role": {
      "type": "string",
      "enum": [
        "host",
        "attendee"
      ]
    },
    "room": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "status",
        "revision"
      ],
      "properties": {
        "status": {
          "type": "string",
          "enum": [
            "notCreated",
            "open",
            "closed"
          ]
        },
        "revision": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        }
      }
    },
    "membership": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "status",
        "revision"
      ],
      "properties": {
        "status": {
          "type": "string",
          "enum": [
            "notJoined",
            "joined",
            "left"
          ]
        },
        "revision": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        }
      }
    },
    "canManage": {
      "type": "boolean"
    },
    "canJoin": {
      "type": "boolean"
    },
    "canReadMessages": {
      "type": "boolean"
    },
    "profileClaimRequired": {
      "type": "boolean"
    },
    "termsVersion": {
      "type": "string",
      "enum": [
        "event-chat-v1"
      ]
    }
  }
} as const;
