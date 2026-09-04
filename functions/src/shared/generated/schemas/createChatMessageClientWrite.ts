/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const createChatMessageClientWriteSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/client_writes/create_chat_message.schema.json",
  "title": "CreateChatMessageClientWrite",
  "description": "Client-owned Firestore create operation for matches/{matchId}/messages/{messageId}.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "path",
    "data"
  ],
  "properties": {
    "path": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "matchId",
        "messageId"
      ],
      "properties": {
        "matchId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "messageId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        }
      }
    },
    "data": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "senderId",
        "text",
        "sentAt"
      ],
      "properties": {
        "senderId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "text": {
          "type": "string",
          "maxLength": 2000
        },
        "imageUrl": {
          "anyOf": [
            {
              "type": "string",
              "format": "uri",
              "maxLength": 2048
            },
            {
              "type": "null"
            }
          ]
        },
        "sentAt": {
          "type": "object",
          "description": "Serialized Firestore Timestamp fixture shape.",
          "x-firestore-type": "timestamp",
          "additionalProperties": false,
          "required": [
            "_seconds",
            "_nanoseconds"
          ],
          "properties": {
            "_seconds": {
              "type": "integer"
            },
            "_nanoseconds": {
              "type": "integer",
              "minimum": 0,
              "maximum": 999999999
            }
          }
        }
      },
      "anyOf": [
        {
          "properties": {
            "text": {
              "type": "string",
              "minLength": 1,
              "maxLength": 2000
            }
          }
        },
        {
          "required": [
            "imageUrl"
          ],
          "properties": {
            "imageUrl": {
              "type": "string",
              "format": "uri",
              "maxLength": 2048
            }
          }
        }
      ]
    }
  },
  "x-firestore-operation": "create",
  "x-firestore-path": "matches/{matchId}/messages/{messageId}",
  "x-owner": "active match participant direct create; moderation and preview fan-out are trigger-owned"
} as const;
