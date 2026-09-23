/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventChatMessageDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_chat_messages.schema.json",
  "title": "EventChatMessageDocument",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "organizerId",
    "uid",
    "sequence",
    "text",
    "replyToMessageId",
    "status",
    "payloadHash",
    "reactionCounts",
    "createdAt",
    "removedAt"
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
    "uid": {
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
    "sequence": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "text": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 2000
        },
        {
          "type": "null"
        }
      ]
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
    "status": {
      "type": "string",
      "enum": [
        "visible",
        "removed"
      ]
    },
    "kind": {
      "type": "string",
      "enum": [
        "text",
        "announcement"
      ],
      "description": "Legacy omission means text."
    },
    "payloadHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "reactionCounts": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "like",
        "love",
        "laugh",
        "wow",
        "sad",
        "thanks"
      ],
      "properties": {
        "like": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "love": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "laugh": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "wow": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "sad": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "thanks": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        }
      }
    },
    "createdAt": {
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
    },
    "removedAt": {
      "anyOf": [
        {
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
        },
        {
          "type": "null"
        }
      ]
    }
  },
  "description": "Server-owned event conversation message; replies are same-room references, never quoted copies.",
  "x-firestore-collection": "eventChatMessages",
  "x-firestore-path": "eventChatMessages/{id}",
  "x-document-id-field": "id",
  "x-owner": "event chat callables"
} as const;
