/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventSetupReceiptDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_setup_receipts.schema.json",
  "title": "EventSetupReceiptDocument",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "operation",
    "actorUid",
    "organizerId",
    "requestHash",
    "eventId",
    "appliedRevision",
    "createdAt"
  ],
  "properties": {
    "operation": {
      "type": "string",
      "enum": [
        "create",
        "update"
      ]
    },
    "actorUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "requestHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "appliedRevision": {
      "type": "integer",
      "minimum": 1
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
  "x-firestore-collection": "eventSetupReceipts",
  "x-firestore-path": "eventSetupReceipts/{receiptId}",
  "x-document-id-field": "receiptId",
  "x-owner": "private event setup operations"
} as const;
