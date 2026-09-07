/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceProgressReceiptDocumentSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "receiptId",
    "progressId",
    "requestHash",
    "revision",
    "createdAt"
  ],
  "properties": {
    "receiptId": {
      "type": "string",
      "pattern": "^progress-action:[a-f0-9]{64}$"
    },
    "progressId": {
      "type": "string",
      "pattern": "^progress:[a-f0-9]{64}$"
    },
    "requestHash": {
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
  "title": "EventAssistanceProgressReceiptDocument",
  "x-firestore-collection": "eventAssistanceProgressReceipts",
  "x-firestore-path": "eventAssistanceProgressReceipts/{receiptId}",
  "x-document-id-field": "receiptId",
  "x-owner": "event-assistance departure command"
} as const;
