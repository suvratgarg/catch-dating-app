/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventChatRoomDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_chat_rooms.schema.json",
  "title": "EventChatRoomDocument",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "organizerId",
    "status",
    "revision",
    "createdByUid",
    "updatedByUid",
    "createdAt",
    "updatedAt"
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
    "status": {
      "type": "string",
      "enum": [
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
    "createdByUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "updatedByUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
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
    "updatedAt": {
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
    "lastMessageSequence": {
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
  },
  "description": "Host-controlled event conversation availability. No attendee admission or profile data.",
  "x-firestore-collection": "eventChatRooms",
  "x-firestore-path": "eventChatRooms/{eventId}",
  "x-document-id-field": "eventId",
  "x-owner": "event chat access callables"
} as const;
