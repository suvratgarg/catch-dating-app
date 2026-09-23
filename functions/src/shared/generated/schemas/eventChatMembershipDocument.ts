/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventChatMembershipDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_chat_memberships.schema.json",
  "title": "EventChatMembershipDocument",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "organizerId",
    "uid",
    "status",
    "revision",
    "termsVersion",
    "joinedAt",
    "leftAt",
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
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "status": {
      "type": "string",
      "enum": [
        "joined",
        "left"
      ]
    },
    "revision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "termsVersion": {
      "type": "string",
      "enum": [
        "event-chat-v1"
      ]
    },
    "joinedAt": {
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
    "leftAt": {
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
    }
  },
  "description": "Explicit room participation. Current admission and claimed identity must still be rechecked on every access.",
  "x-firestore-collection": "eventChatMemberships",
  "x-firestore-path": "eventChatMemberships/{membershipId}",
  "x-document-id-field": "membershipId",
  "x-owner": "event chat access callables"
} as const;
