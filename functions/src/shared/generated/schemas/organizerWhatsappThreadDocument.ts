/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerWhatsappThreadDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_whatsapp_threads.schema.json",
  "title": "OrganizerWhatsappThreadDocument",
  "description": "Server-only organizer/contact WhatsApp thread summary with a 12-month rolling retention boundary.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerWhatsappThreads",
  "x-firestore-path": "organizerWhatsappThreads/{threadId}",
  "x-document-id-field": "threadId",
  "x-owner": "organizer WhatsApp inbox and reply callables",
  "required": [
    "schemaVersion",
    "threadId",
    "organizerId",
    "contactId",
    "connectionId",
    "endpointHash",
    "eventIds",
    "lastMessageBody",
    "lastMessageDirection",
    "lastMessageAt",
    "lastInboundAt",
    "serviceWindowExpiresAt",
    "messageCount",
    "createdAt",
    "updatedAt",
    "expiresAt"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "threadId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "contactId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "connectionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "endpointHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "eventIds": {
      "type": "array",
      "maxItems": 50,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      }
    },
    "lastMessageBody": {
      "type": "string",
      "minLength": 1,
      "maxLength": 4096
    },
    "lastMessageDirection": {
      "type": "string",
      "enum": [
        "inbound",
        "outbound"
      ]
    },
    "lastMessageAt": {
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
    "lastInboundAt": {
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
    "serviceWindowExpiresAt": {
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
    "messageCount": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000000
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
