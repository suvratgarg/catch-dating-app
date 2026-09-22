/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerFormPaymentWebhookDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_form_payment_webhooks.schema.json",
  "title": "OrganizerFormPaymentWebhookDocument",
  "description": "Deduplicated, verified merchant webhook receipt. Raw provider payloads and credentials are never stored.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "connectionId",
    "accountId",
    "providerEventId",
    "event",
    "providerOrderId",
    "providerPaymentId",
    "status",
    "createdAt",
    "processedAt",
    "expiresAt"
  ],
  "properties": {
    "connectionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "accountId": {
      "type": "string",
      "pattern": "^acc_[A-Za-z0-9]+$"
    },
    "providerEventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 200
    },
    "event": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80
    },
    "providerOrderId": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^order_[A-Za-z0-9]+$"
    },
    "providerPaymentId": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^pay_[A-Za-z0-9]+$"
    },
    "status": {
      "enum": [
        "pending",
        "processed",
        "ignored"
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
      }
    }
  },
  "x-firestore-collection": "organizerFormPaymentWebhooks",
  "x-firestore-path": "organizerFormPaymentWebhooks/{receiptId}",
  "x-document-id-field": "receiptId",
  "x-owner": "organizer form payment server operations"
} as const;
