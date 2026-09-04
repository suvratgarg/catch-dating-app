/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerCampaignWebhookReceiptDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_campaign_webhook_receipts.schema.json",
  "title": "OrganizerCampaignWebhookReceiptDocument",
  "description": "TTL idempotency receipt for one authenticated provider webhook event.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerCampaignWebhookReceipts",
  "x-firestore-path": "organizerCampaignWebhookReceipts/{receiptId}",
  "x-document-id-field": "receiptId",
  "x-owner": "WhatsApp provider webhook",
  "required": [
    "provider",
    "providerEventId",
    "organizerId",
    "connectionId",
    "eventKind",
    "payloadHash",
    "createdAt",
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
    "payloadHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
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
    }
  }
} as const;
