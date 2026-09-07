/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceAccountabilityReceiptDocumentSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "receiptId",
    "guestId",
    "requestHash",
    "sourceGeneration",
    "attendeeGeneration",
    "checkInHash",
    "episodeId",
    "revision",
    "disposition",
    "createdAt"
  ],
  "properties": {
    "receiptId": {
      "type": "string",
      "pattern": "^accountability-action:[a-f0-9]{64}$"
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
    "attendeeGeneration": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "checkInHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "episodeId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        {
          "type": "null"
        }
      ]
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "disposition": {
      "enum": [
        "returned",
        "departed",
        "unresolved"
      ]
    },
    "createdAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    }
  },
  "title": "EventAssistanceAccountabilityReceiptDocument",
  "x-firestore-collection": "eventAssistanceAccountabilityReceipts",
  "x-firestore-path": "eventAssistanceAccountabilityReceipts/{receiptId}",
  "x-document-id-field": "receiptId",
  "x-owner": "event-assistance accountability command"
} as const;
