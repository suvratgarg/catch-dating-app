/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesIntelligenceReceiptsDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/sales_intelligence_receipts.schema.json",
  "title": "SalesIntelligenceReceiptDocument",
  "description": "Immutable employee-scoped exact-retry receipt for private policy, evidence assessment, score, clause and manual-copy actions. Never proof of sending.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "salesIntelligenceReceipts",
  "x-firestore-path": "salesIntelligenceReceipts/{receiptId}",
  "x-document-id-field": "receiptId",
  "x-owner": "private Sales intelligence mutation service",
  "required": [
    "schemaVersion",
    "classification",
    "receiptId",
    "actorUid",
    "action",
    "requestId",
    "materialHash",
    "result",
    "createdAt"
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
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "actorUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "action": {
      "enum": [
        "policy.save",
        "assessment.save",
        "clause.save",
        "clause.review",
        "score.snapshot",
        "draft.record",
        "draft.review",
        "draft.copy"
      ]
    },
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "materialHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "result": {
      "type": "object",
      "maxProperties": 10
    },
    "createdAt": {
      "type": "string",
      "format": "date-time"
    }
  },
  "definitions": {
    "id": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    }
  }
} as const;
