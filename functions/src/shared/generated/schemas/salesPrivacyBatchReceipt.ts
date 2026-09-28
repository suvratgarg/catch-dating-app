/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesPrivacyBatchReceiptSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/sales_privacy_batch_receipts.schema.json",
  "title": "SalesPrivacyBatchReceipt",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "classification",
    "receiptId",
    "organizerId",
    "planId",
    "expectedCursor",
    "requestId",
    "result",
    "createdAt",
    "actorUid"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "classification": {
      "const": "sales_private"
    },
    "receiptId": {
      "type": "string",
      "pattern": "^privacy-batch-[a-f0-9]{40}$"
    },
    "organizerId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]{0,179}$"
    },
    "planId": {
      "type": "string",
      "pattern": "^privacy-[a-f0-9]{40}$"
    },
    "expectedCursor": {
      "type": "integer",
      "minimum": 0,
      "maximum": 240
    },
    "requestId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]{7,95}$"
    },
    "result": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "organizerId",
        "planId",
        "previousCursor",
        "nextCursor",
        "itemCount",
        "deletedCount",
        "retainedCount",
        "unresolvedCount",
        "status",
        "completeDeletion",
        "receiptId"
      ],
      "properties": {
        "organizerId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]{0,179}$"
        },
        "planId": {
          "type": "string",
          "pattern": "^privacy-[a-f0-9]{40}$"
        },
        "previousCursor": {
          "type": "integer",
          "minimum": 0
        },
        "nextCursor": {
          "type": "integer",
          "minimum": 0
        },
        "itemCount": {
          "type": "integer",
          "minimum": 0
        },
        "deletedCount": {
          "type": "integer",
          "minimum": 0
        },
        "retainedCount": {
          "type": "integer",
          "minimum": 0
        },
        "unresolvedCount": {
          "type": "integer",
          "minimum": 0
        },
        "status": {
          "enum": [
            "processing",
            "internal_processed_with_unresolved"
          ]
        },
        "completeDeletion": {
          "const": false
        },
        "receiptId": {
          "type": "string",
          "pattern": "^privacy-batch-[a-f0-9]{40}$"
        }
      }
    },
    "createdAt": {
      "type": "string",
      "format": "date-time"
    },
    "actorUid": {
      "type": "string",
      "minLength": 1
    }
  },
  "x-firestore-collection": "salesPrivacyBatchReceipts",
  "x-firestore-path": "salesPrivacyBatchReceipts/{id}",
  "x-owner": "Private Sales privacy lifecycle"
} as const;
