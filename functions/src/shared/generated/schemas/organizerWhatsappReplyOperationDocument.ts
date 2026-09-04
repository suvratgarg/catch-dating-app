/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerWhatsappReplyOperationDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_whatsapp_reply_operations.schema.json",
  "title": "OrganizerWhatsappReplyOperationDocument",
  "description": "Server-only at-most-once reservation for one organizer WhatsApp reply attempt.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerWhatsappReplyOperations",
  "x-firestore-path": "organizerWhatsappReplyOperations/{operationId}",
  "x-document-id-field": "operationId",
  "x-owner": "sendOrganizerWhatsappReply callable",
  "required": [
    "schemaVersion",
    "operationId",
    "organizerId",
    "threadId",
    "contactId",
    "messageId",
    "bodyHash",
    "expectedLastInboundAtMillis",
    "actorUid",
    "state",
    "providerMessageId",
    "createdAt",
    "updatedAt",
    "expiresAt"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "operationId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "threadId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "contactId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "messageId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "bodyHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "expectedLastInboundAtMillis": {
      "type": "integer",
      "minimum": 0
    },
    "actorUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "state": {
      "type": "string",
      "enum": [
        "pending",
        "completed",
        "unknown"
      ]
    },
    "providerMessageId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 240
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
      "x-firestore-ttl": true
    }
  }
} as const;
