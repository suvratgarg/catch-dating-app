/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerProviderConnectionDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_provider_connections.schema.json",
  "title": "OrganizerProviderConnectionDocument",
  "description": "Safe organizer-owned booking-provider connection metadata. Provider credentials live in Secret Manager, never Firestore.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerProviderConnections",
  "x-firestore-path": "organizerProviderConnections/{connectionId}",
  "x-document-id-field": "connectionId",
  "x-owner": "organizer provider connection and health callables",
  "required": [
    "organizerId",
    "provider",
    "adapterClass",
    "status",
    "externalAccountId",
    "externalAccountName",
    "secretVersionResource",
    "syncMode",
    "capabilities",
    "connectedByUid",
    "revision",
    "createdAt",
    "updatedAt",
    "lastHealthSyncAt",
    "lastSuccessfulSyncAt",
    "lastErrorCode",
    "disconnectedAt"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "provider": {
      "const": "luma"
    },
    "adapterClass": {
      "const": "A"
    },
    "status": {
      "type": "string",
      "enum": [
        "active",
        "degraded",
        "credentialRevoked",
        "disconnected"
      ]
    },
    "externalAccountId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "externalAccountName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "secretVersionResource": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^projects/[^/]+/secrets/[^/]+/versions/[0-9]+$"
    },
    "syncMode": {
      "const": "manualPoll"
    },
    "capabilities": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "eventList",
        "rosterIdentity",
        "registrationStatus",
        "providerCheckIn",
        "orderAmount",
        "refundStatus",
        "referralCode",
        "webhooks",
        "writeBookings"
      ],
      "properties": {
        "eventList": {
          "type": "boolean"
        },
        "rosterIdentity": {
          "type": "boolean"
        },
        "registrationStatus": {
          "type": "boolean"
        },
        "providerCheckIn": {
          "type": "boolean"
        },
        "orderAmount": {
          "type": "boolean"
        },
        "refundStatus": {
          "type": "boolean"
        },
        "referralCode": {
          "type": "boolean"
        },
        "webhooks": {
          "type": "boolean"
        },
        "writeBookings": {
          "type": "boolean"
        }
      }
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
    "lastSuccessfulSyncAt": {
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
    "lastErrorCode": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 80
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
