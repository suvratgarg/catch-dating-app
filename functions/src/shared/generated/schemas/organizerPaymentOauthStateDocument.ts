/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerPaymentOauthStateDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_payment_oauth_states.schema.json",
  "title": "OrganizerPaymentOauthStateDocument",
  "description": "Single-use hashed OAuth state bound to initiating user, organizer, connection and mode.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "connectionId",
    "actorUid",
    "mode",
    "status",
    "createdAt",
    "expiresAt",
    "completedAt"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "connectionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "actorUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "mode": {
      "enum": [
        "test",
        "live"
      ],
      "type": "string"
    },
    "status": {
      "enum": [
        "pending",
        "exchanging",
        "completed",
        "failed"
      ],
      "type": "string"
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
    },
    "completedAt": {
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
  "x-firestore-collection": "organizerPaymentOauthStates",
  "x-firestore-path": "organizerPaymentOauthStates/{stateHash}",
  "x-document-id-field": "stateHash",
  "x-owner": "organizer form payment server operations"
} as const;
