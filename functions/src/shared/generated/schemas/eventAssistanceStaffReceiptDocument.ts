/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceStaffReceiptDocumentSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "receiptId",
    "staffGrantId",
    "sourceHash",
    "requestHash",
    "revision",
    "createdAt"
  ],
  "properties": {
    "receiptId": {
      "type": "string",
      "pattern": "^staff-action:[a-f0-9]{64}$"
    },
    "staffGrantId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 500
    },
    "sourceHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
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
  "title": "EventAssistanceStaffReceiptDocument",
  "x-firestore-collection": "eventAssistanceStaffReceipts",
  "x-firestore-path": "eventAssistanceStaffReceipts/{receiptId}",
  "x-document-id-field": "receiptId",
  "x-owner": "event staff group duties"
} as const;
