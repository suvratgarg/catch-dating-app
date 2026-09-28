/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const assistantGatewayBudgetsDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/assistant_gateway_budgets.schema.json",
  "title": "AssistantGatewayBudgetDocument",
  "description": "Transactional request counter for one delegated client or owner window.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "classification",
    "budgetId",
    "windowKind",
    "count",
    "expiresAt"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "classification": {
      "const": "sales_private"
    },
    "budgetId": {
      "type": "string",
      "minLength": 43,
      "maxLength": 70,
      "pattern": "^[a-f0-9]{40}_[md]_[A-Za-z0-9-]+$"
    },
    "windowKind": {
      "enum": [
        "minute",
        "day"
      ]
    },
    "count": {
      "type": "integer",
      "minimum": 1
    },
    "expiresAt": {
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
  },
  "x-firestore-collection": "assistantGatewayBudgets",
  "x-firestore-path": "assistantGatewayBudgets/{budgetId}",
  "x-document-id-field": "budgetId",
  "x-owner": "sales assistant gateway server-only budget transaction"
} as const;
