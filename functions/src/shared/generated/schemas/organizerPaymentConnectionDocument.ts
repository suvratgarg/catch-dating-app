/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerPaymentConnectionDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_payment_connections.schema.json",
  "title": "OrganizerPaymentConnectionDocument",
  "description": "Merchant-owned Razorpay OAuth connection. Secret values are held in the bound credential vault; this server-only document contains pinned references.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "provider",
    "mode",
    "status",
    "accountId",
    "publicToken",
    "secretVersionResource",
    "tokenExpiresAt",
    "webhookId",
    "webhookUrl",
    "webhookVerifiedAt",
    "connectedByUid",
    "revision",
    "refreshLeaseUntil",
    "createdAt",
    "updatedAt",
    "disconnectedAt",
    "lastErrorCode"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "provider": {
      "const": "razorpay"
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
        "connecting",
        "ready",
        "needsAttention",
        "disconnected"
      ],
      "type": "string"
    },
    "accountId": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^acc_[A-Za-z0-9]+$"
    },
    "publicToken": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 256
    },
    "secretVersionResource": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^projects/[^/]+/secrets/[^/]+/versions/[1-9][0-9]*$"
    },
    "tokenExpiresAt": {
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
    "webhookId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 128
    },
    "webhookUrl": {
      "type": [
        "string",
        "null"
      ],
      "format": "uri",
      "maxLength": 255
    },
    "webhookVerifiedAt": {
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
    "connectedByUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "revision": {
      "type": "integer",
      "minimum": 1
    },
    "refreshLeaseUntil": {
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
    },
    "lastErrorCode": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 80
    }
  },
  "x-firestore-collection": "organizerPaymentConnections",
  "x-firestore-path": "organizerPaymentConnections/{connectionId}",
  "x-document-id-field": "connectionId",
  "x-owner": "organizer form payment server operations"
} as const;
