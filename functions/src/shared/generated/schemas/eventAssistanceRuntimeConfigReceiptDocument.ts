/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceRuntimeConfigReceiptDocumentSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "receiptId",
    "runtimeId",
    "requestHash",
    "sourceGeneration",
    "revision",
    "createdAt"
  ],
  "properties": {
    "receiptId": {
      "type": "string",
      "pattern": "^runtime-action:[a-f0-9]{64}$"
    },
    "runtimeId": {
      "type": "string",
      "pattern": "^runtime:lateJoin:[a-f0-9]{64}$"
    },
    "requestHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "sourceGeneration": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "createdAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    }
  },
  "title": "EventAssistanceRuntimeConfigReceiptDocument",
  "x-firestore-collection": "eventAssistanceRuntimeConfigReceipts",
  "x-firestore-path": "eventAssistanceRuntimeConfigReceipts/{receiptId}",
  "x-document-id-field": "receiptId",
  "x-owner": "event-assistance runtime configuration"
} as const;
