/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listEventChatsCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/list_event_chats_response.schema.json",
  "title": "ListEventChatsCallableResponse",
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
          "canPostMessages",
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
                  "scheduled",
                  "open",
                  "announcementsOnly",
                  "paused",
                  "closed",
                  "archived"
                ]
              },
              "revision": {
                "type": "integer",
                "minimum": 0,
                "maximum": 9007199254740991
              },
              "opensAtMillis": {
                "type": [
                  "integer",
                  "null"
                ],
                "minimum": 0
              },
              "closesAtMillis": {
                "type": [
                  "integer",
                  "null"
                ],
                "minimum": 0
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
                  "left",
                  "removed",
                  "banned"
                ]
              },
              "revision": {
                "type": "integer",
                "minimum": 0,
                "maximum": 9007199254740991
              },
              "notificationsMuted": {
                "type": "boolean"
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
          "canPostMessages": {
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
      }
    },
    "nextCursor": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "source",
            "after",
            "accountUid"
          ],
          "properties": {
            "source": {
              "type": "string",
              "enum": [
                "memberships",
                "participations",
                "attendees"
              ]
            },
            "after": {
              "anyOf": [
                {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 1500,
                  "pattern": "^[^/]+$"
                },
                {
                  "type": "null"
                }
              ]
            },
            "accountUid": {
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
