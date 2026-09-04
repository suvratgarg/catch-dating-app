/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventVenueSessionRedemptionDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_venue_session_redemptions.schema.json",
  "title": "EventVenueSessionRedemptionDocument",
  "description": "Server-only single-use receipt binding one attendee to one live venue session.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventVenueSessionRedemptions",
  "x-firestore-path": "eventVenueSessionRedemptions/{redemptionId}",
  "x-document-id-field": "redemptionId",
  "x-owner": "attendance and First Hello callables; no client reads or writes",
  "required": [
    "eventId",
    "sessionId",
    "uid",
    "purpose",
    "redeemedAt",
    "consumedAt",
    "expiresAt"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "sessionId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{24,80}$"
    },
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "purpose": {
      "type": "string",
      "enum": [
        "attendance",
        "firstHello"
      ]
    },
    "redeemedAt": {
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
    "consumedAt": {
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
    "expiresAt": {
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
