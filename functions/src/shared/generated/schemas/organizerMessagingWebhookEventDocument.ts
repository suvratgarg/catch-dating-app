/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerMessagingWebhookEventDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_messaging_webhook_events.schema.json",
  "title": "OrganizerMessagingWebhookEventDocument",
  "description": "Sanitized durable provider event queued after signature verification. Inbound text is retained here for at most 30 days and copied into the organizer thread store for at most 12 months.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerMessagingWebhookEvents",
  "x-firestore-path": "organizerMessagingWebhookEvents/{eventId}",
  "x-document-id-field": "eventId",
  "x-owner": "WhatsApp webhook ingress and receipt processor",
  "required": [
    "provider",
    "providerEventId",
    "organizerId",
    "connectionId",
    "eventKind",
    "providerMessageId",
    "contextProviderMessageId",
    "deliveryStatus",
    "endpointHash",
    "isStop",
    "hasReply",
    "inboundBody",
    "providerErrorCode",
    "providerOccurredAt",
    "processingStatus",
    "attemptCount",
    "createdAt",
    "processedAt",
    "expiresAt"
  ],
  "properties": {
    "provider": {
      "const": "metaCloudApi"
    },
    "providerEventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "organizerId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "connectionId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "eventKind": {
      "type": "string",
      "enum": [
        "status",
        "inbound",
        "template",
        "quality",
        "account",
        "unmatched"
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
    "contextProviderMessageId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 240
    },
    "deliveryStatus": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        null,
        "sent",
        "delivered",
        "read",
        "failed"
      ]
    },
    "endpointHash": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^[a-f0-9]{64}$"
    },
    "isStop": {
      "type": "boolean"
    },
    "hasReply": {
      "type": "boolean"
    },
    "inboundBody": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 4096
    },
    "providerErrorCode": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 0,
      "maximum": 999999999
    },
    "providerOccurredAt": {
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
    "processingStatus": {
      "type": "string",
      "enum": [
        "pending",
        "processed",
        "unmatched",
        "failed"
      ]
    },
    "attemptCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100
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
    "processedAt": {
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
      },
      "x-firestore-ttl": true
    }
  }
} as const;
