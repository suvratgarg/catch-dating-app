/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventChatAccessReceiptDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_chat_access_receipts.schema.json",
  "title": "EventChatAccessReceiptDocument",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "uid",
    "payloadHash",
    "revision",
    "createdAt"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "payloadHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "revision": {
      "type": "integer",
      "minimum": 0,
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
    }
  },
  "description": "Payload-bound idempotency receipt for an explicit room availability or membership change.",
  "x-firestore-collection": "eventChatAccessReceipts",
  "x-firestore-path": "eventChatAccessReceipts/{receiptId}",
  "x-document-id-field": "receiptId",
  "x-owner": "event chat access callables"
} as const;
