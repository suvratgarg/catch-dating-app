/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const functionEventReceiptDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/function_event_receipts.schema.json",
  "title": "FunctionEventReceiptDocument",
  "description": "Server-owned idempotency receipt stored at functionEventReceipts/{receiptId}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "functionEventReceipts",
  "x-firestore-path": "functionEventReceipts/{receiptId}",
  "x-document-id-field": "receiptId",
  "x-owner": "idempotent Firestore trigger handlers",
  "required": [
    "handler",
    "createdAt"
  ],
  "properties": {
    "handler": {
      "type": "string",
      "enum": [
        "onMessageCreated",
        "onMatchCreated",
        "moderatePhotoOnUpload"
      ],
      "x-catch-ownership": "server-only"
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240,
      "x-catch-ownership": "server-only"
    },
    "matchId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "messageId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
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
      "x-catch-ownership": "server-only"
    }
  }
} as const;
