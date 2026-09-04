/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerSenderConnectionDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_sender_connections.schema.json",
  "title": "OrganizerSenderConnectionDocument",
  "description": "Safe organizer-owned messaging sender metadata. Provider access tokens live in Secret Manager, never Firestore.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerSenderConnections",
  "x-firestore-path": "organizerSenderConnections/{connectionId}",
  "x-document-id-field": "connectionId",
  "x-owner": "organizer messaging sender onboarding and provider health sync",
  "required": [
    "organizerId",
    "channel",
    "provider",
    "status",
    "wabaId",
    "phoneNumberId",
    "businessId",
    "displayPhoneNumber",
    "verifiedName",
    "secretVersionResource",
    "qualityRating",
    "messagingLimitTier",
    "templateSyncStatus",
    "webhookStatus",
    "testStatus",
    "testProviderMessageId",
    "testRecipientHash",
    "connectedByUid",
    "revision",
    "createdAt",
    "updatedAt",
    "disconnectedAt"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "channel": {
      "const": "whatsapp"
    },
    "provider": {
      "const": "metaCloudApi"
    },
    "status": {
      "type": "string",
      "enum": [
        "pending",
        "testing",
        "active",
        "degraded",
        "blocked",
        "tokenRevoked",
        "disconnected"
      ]
    },
    "wabaId": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^[0-9]{5,40}$"
    },
    "phoneNumberId": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^[0-9]{5,40}$"
    },
    "businessId": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^[0-9]{5,40}$"
    },
    "displayPhoneNumber": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 7,
      "maxLength": 32
    },
    "verifiedName": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 160
    },
    "secretVersionResource": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^projects/[^/]+/secrets/[^/]+/versions/[0-9]+$"
    },
    "qualityRating": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        null,
        "GREEN",
        "YELLOW",
        "RED",
        "UNKNOWN"
      ]
    },
    "messagingLimitTier": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 80
    },
    "templateSyncStatus": {
      "type": "string",
      "enum": [
        "notStarted",
        "current",
        "stale",
        "failed"
      ]
    },
    "webhookStatus": {
      "type": "string",
      "enum": [
        "notSubscribed",
        "subscribed",
        "degraded"
      ]
    },
    "testStatus": {
      "type": "string",
      "enum": [
        "notSent",
        "pending",
        "delivered",
        "failed"
      ]
    },
    "testProviderMessageId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 240
    },
    "testRecipientHash": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^[a-f0-9]{64}$"
    },
    "connectedByUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
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
    "lastHealthSyncAt": {
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
    "disconnectedAt": {
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
  }
} as const;
