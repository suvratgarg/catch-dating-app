/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const crossPathsPairHoldDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/cross_paths_pair_holds.schema.json",
  "title": "CrossPathsPairHoldDocument",
  "description": "Server-owned, short-lived companion-seat reservation for an accepted Cross Paths invitation.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "cross_paths_pair_holds",
  "x-firestore-path": "crossPathsPairHolds/{holdId}",
  "x-document-id-field": "id",
  "x-owner": "Cross Paths pair-inventory callables and payment fulfillment",
  "required": [
    "eventId",
    "invitationId",
    "organizerId",
    "requesterUid",
    "attendeeUid",
    "participantIds",
    "status",
    "requesterBookingStatus",
    "attendeeBookingStatus",
    "requesterCohortId",
    "attendeeCohortId",
    "requesterPriceInPaise",
    "attendeePriceInPaise",
    "currency",
    "createdAt",
    "updatedAt",
    "expiresAt",
    "confirmedAt",
    "releasedAt",
    "releaseReason",
    "paymentId",
    "conversationId"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "invitationId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "requesterUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "attendeeUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "participantIds": {
      "type": "array",
      "minItems": 2,
      "maxItems": 2,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      },
      "x-catch-ownership": "callable-owned"
    },
    "status": {
      "type": "string",
      "enum": [
        "active",
        "confirmed",
        "expired",
        "cancelled",
        "invalidated"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "requesterBookingStatus": {
      "type": "string",
      "enum": [
        "held",
        "confirmed",
        "cancelled"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "attendeeBookingStatus": {
      "type": "string",
      "enum": [
        "confirmed",
        "cancelled"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "requesterCohortId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "x-catch-ownership": "callable-owned"
    },
    "attendeeCohortId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "x-catch-ownership": "callable-owned"
    },
    "requesterPriceInPaise": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100000000,
      "x-catch-ownership": "callable-owned"
    },
    "attendeePriceInPaise": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100000000,
      "x-catch-ownership": "callable-owned"
    },
    "currency": {
      "type": "string",
      "pattern": "^[A-Z]{3}$",
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
    },
    "confirmedAt": {
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
      ],
      "x-catch-ownership": "callable-owned"
    },
    "releasedAt": {
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
      ],
      "x-catch-ownership": "callable-owned"
    },
    "releaseReason": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        null,
        "expired",
        "cancelled",
        "event_unavailable",
        "participation_cancelled",
        "safety_state_changed",
        "payment_failed"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "paymentId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "conversationId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    }
  }
} as const;
