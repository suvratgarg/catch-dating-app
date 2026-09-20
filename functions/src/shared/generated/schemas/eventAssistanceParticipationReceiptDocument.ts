/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceParticipationReceiptDocumentSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "receiptId",
    "guestId",
    "requestHash",
    "sourceGeneration",
    "revision",
    "episodeId",
    "createdAt"
  ],
  "properties": {
    "receiptId": {
      "type": "string",
      "pattern": "^participation-action:[a-f0-9]{64}$"
    },
    "guestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
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
    "episodeId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "createdAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    }
  },
  "title": "EventAssistanceParticipationReceiptDocument",
  "x-firestore-collection": "eventAssistanceParticipationReceipts",
  "x-firestore-path": "eventAssistanceParticipationReceipts/{receiptId}",
  "x-document-id-field": "receiptId",
  "x-owner": "event-assistance participation command"
} as const;
