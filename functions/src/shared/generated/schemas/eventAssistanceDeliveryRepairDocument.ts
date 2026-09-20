/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceDeliveryRepairDocumentSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "receiptId",
    "context",
    "messageId",
    "intentHash",
    "requestHash",
    "actorUid",
    "operationId",
    "messageRevision",
    "createdAt"
  ],
  "properties": {
    "receiptId": {
      "type": "string",
      "pattern": "^delivery-repair:[a-f0-9]{64}$"
    },
    "context": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "mode",
        "eventId",
        "organizerId"
      ],
      "properties": {
        "mode": {
          "type": "string",
          "const": "live"
        },
        "eventId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "organizerId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 2000
        }
      }
    },
    "messageId": {
      "type": "string",
      "pattern": "^outbox:[a-f0-9]{64}$"
    },
    "intentHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "requestHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "actorUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "operationId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "messageRevision": {
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
  "title": "EventAssistanceDeliveryRepairDocument",
  "x-firestore-collection": "eventAssistanceDeliveryRepairs",
  "x-firestore-path": "eventAssistanceDeliveryRepairs/{receiptId}",
  "x-document-id-field": "receiptId",
  "x-owner": "trusted event-assistance host recovery"
} as const;
