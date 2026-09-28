/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesFitQueueMetaDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/sales_fit_queue_meta.schema.json",
  "title": "SalesFitQueueMetaDocument",
  "description": "Private generation fence incremented atomically by every fit refresh and source invalidation.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "salesFitQueueMeta",
  "x-firestore-path": "salesFitQueueMeta/{metaId}",
  "x-document-id-field": "metaId",
  "x-owner": "private Sales fit queue service and source mutation hooks",
  "required": [
    "schemaVersion",
    "classification",
    "metaId",
    "generation",
    "updatedAt"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "classification": {
      "const": "sales_private"
    },
    "metaId": {
      "const": "current"
    },
    "generation": {
      "type": "integer",
      "minimum": 1
    },
    "updatedAt": {
      "type": "string",
      "format": "date-time"
    }
  }
} as const;
