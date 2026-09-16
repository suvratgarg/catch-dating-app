/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminDecideEventMessagingBudgetCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/admin_decide_event_messaging_budget_response.schema.json",
  "title": "AdminDecideEventMessagingBudgetCallableResponse",
  "description": "Result of recording a finance review decision. The response explicitly grants no spending authority.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "applied",
    "replayed",
    "decisionId",
    "revision",
    "decisionStatus",
    "decisionPath",
    "effect",
    "grantsSpendingAuthority"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "applied": {
      "type": "boolean"
    },
    "replayed": {
      "type": "boolean"
    },
    "decisionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
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
    }
  }
} as const;
