/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventChatReactionDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_chat_reactions.schema.json",
  "title": "EventChatReactionDocument",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "messageId",
    "uid",
    "reaction",
    "revision",
    "updatedAt"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "messageId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "reaction": {
      "anyOf": [
        {
          "type": "string",
          "enum": [
            "like",
            "love",
            "laugh",
            "wow",
            "sad",
            "thanks"
          ]
        },
        {
          "type": "null"
        }
      ]
    },
    "revision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
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
  "description": "One current reaction per account and message; separate from aggregated anonymous counts.",
  "x-firestore-collection": "eventChatReactions",
  "x-firestore-path": "eventChatReactions/{id}",
  "x-document-id-field": "id",
  "x-owner": "event chat callables"
} as const;
