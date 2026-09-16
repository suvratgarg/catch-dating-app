/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventMessagingBudgetDecisionReceiptDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_messaging_budget_decision_receipts.schema.json",
  "title": "EventMessagingBudgetDecisionReceiptDocument",
  "description": "Immutable request receipt for an event-messaging budget decision. It preserves exact replay without granting spending authority.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventMessagingBudgetDecisionReceipts",
  "x-firestore-path": "eventMessagingBudgetDecisionReceipts/{receiptId}",
  "x-document-id-field": "receiptId",
  "x-owner": "adminDecideEventMessagingBudget callable",
  "required": [
    "schemaVersion",
    "receiptId",
    "decisionId",
    "requestId",
    "requestHash",
    "revision",
    "decisionStatus",
    "decisionPath",
    "effect",
    "grantsSpendingAuthority",
    "createdAt"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "receiptId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "decisionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
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
    "decisionStatus": {
      "type": "string",
      "enum": [
        "approved",
        "held",
        "rejected"
      ]
    },
    "decisionPath": {
      "type": "string",
      "minLength": 1,
      "maxLength": 500
    },
    "effect": {
      "type": "string",
      "const": "decision_only_no_spending_authority"
    },
    "grantsSpendingAuthority": {
      "type": "boolean",
      "const": false
    },
    "createdAt": {
      "type": "object",
      "description": "Serialized Firestore Timestamp fixture shape.",
      "x-firestore-type": "timestamp",
      "additionalProperties": false,
      "required": [
        "_seconds",
        "_nanoseconds"
      ],
      "properties": {
        "_seconds": {
          "type": "integer"
        },
        "_nanoseconds": {
          "type": "integer",
          "minimum": 0,
          "maximum": 999999999
        }
      }
    }
  }
} as const;
