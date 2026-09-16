/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceSettingReceiptDocumentSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "receiptId",
    "settingId",
    "requestHash",
    "revision",
    "createdAt"
  ],
  "properties": {
    "receiptId": {
      "type": "string",
      "pattern": "^setting-action:[a-f0-9]{64}$"
    },
    "settingId": {
      "type": "string",
      "pattern": "^setting:[a-f0-9]{64}$"
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
  "title": "EventAssistanceSettingReceiptDocument",
  "x-firestore-collection": "eventAssistanceSettingReceipts",
  "x-firestore-path": "eventAssistanceSettingReceipts/{receiptId}",
  "x-document-id-field": "receiptId",
  "x-owner": "event-assistance policy configuration"
} as const;
