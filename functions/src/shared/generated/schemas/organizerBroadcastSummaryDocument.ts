/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerBroadcastSummaryDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_broadcast_summaries.schema.json",
  "title": "OrganizerBroadcastSummaryDocument",
  "description": "Server-owned organizer-scoped index of one completed event announcement, including bounded contact delivery state for CRM history.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerBroadcastSummaries",
  "x-firestore-path": "organizerBroadcastSummaries/{broadcastId}",
  "x-document-id-field": "broadcastId",
  "x-owner": "sendEventBroadcast callable",
  "required": [
    "organizerId",
    "broadcastId",
    "eventId",
    "eventName",
    "audience",
    "recipientCount",
    "sentAt",
    "partialFailure",
    "recipientContactIds",
    "recipientDeliveryStates",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "broadcastId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "eventName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160
    },
    "audience": {
      "type": "string",
      "enum": [
        "booked",
        "prospective",
        "everyone"
      ]
    },
    "recipientCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 500
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
    },
    "partialFailure": {
      "type": "boolean"
    },
    "recipientContactIds": {
      "type": "array",
      "maxItems": 500,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      }
    },
    "recipientDeliveryStates": {
      "type": "object",
      "maxProperties": 500,
      "additionalProperties": {
        "type": "string",
        "enum": [
          "available",
          "failed"
        ]
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
  }
} as const;
