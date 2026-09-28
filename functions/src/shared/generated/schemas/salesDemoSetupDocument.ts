/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesDemoSetupDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/sales_demo_setups.schema.json",
  "title": "SalesDemoSetupDocument",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "classification",
    "setupId",
    "organizerId",
    "blueprintId",
    "blueprintRevision",
    "setupHash",
    "formId",
    "createdByUid",
    "createdAt"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "classification": {
      "const": "sales_private"
    },
    "setupId": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "organizerId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "blueprintId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "blueprintRevision": {
      "type": "integer",
      "minimum": 1
    },
    "setupHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "formId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "createdByUid": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "createdAt": {
      "type": "string",
      "format": "date-time"
    }
  },
  "x-firestore-collection": "salesDemoSetups",
  "x-firestore-path": "salesDemoSetups/{setupId}",
  "x-document-id-field": "setupId",
  "x-owner": "verified organizer demo setup boundary"
} as const;
