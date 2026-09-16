/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminApplyEventMessagingBudgetCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/admin_apply_event_messaging_budget_response.schema.json",
  "title": "AdminApplyEventMessagingBudgetCallableResponse",
  "description": "Result of staging an approved event-messaging budget decision as two paused ceilings. Staging grants no spending or dispatch authority and cannot activate a worker.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "applied",
    "replayed",
    "decisionId",
    "decisionRevision",
    "receiptId",
    "receiptPath",
    "routeId",
    "eventBudget",
    "senderDayBudget",
    "effect",
    "stagesSpendingCeilings",
    "grantsSpendingAuthority",
    "grantsDispatchAuthority",
    "providerContacted",
    "workerActivated"
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
    "decisionRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "receiptId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "receiptPath": {
      "type": "string",
      "minLength": 1,
      "maxLength": 500
    },
    "routeId": {
      "type": "string",
      "enum": [
        "catchEventSms",
        "catchEventRcs",
        "organizerEventWhatsapp"
      ]
    },
    "eventBudget": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "budgetId",
        "revision",
        "path",
        "status"
      ],
      "properties": {
        "budgetId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "revision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        },
        "path": {
          "type": "string",
          "minLength": 1,
          "maxLength": 500
        },
        "status": {
          "type": "string",
          "const": "paused"
        }
      }
    },
    "senderDayBudget": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "budgetId",
        "revision",
        "path",
        "status"
      ],
      "properties": {
        "budgetId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "revision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        },
        "path": {
          "type": "string",
          "minLength": 1,
          "maxLength": 500
        },
        "status": {
          "type": "string",
          "const": "paused"
        }
      }
    },
    "effect": {
      "type": "string",
      "const": "budgets_staged_paused_no_spending_or_dispatch_authority"
    },
    "stagesSpendingCeilings": {
      "type": "boolean",
      "const": true
    },
    "grantsSpendingAuthority": {
      "type": "boolean",
      "const": false
    },
    "grantsDispatchAuthority": {
      "type": "boolean",
      "const": false
    },
    "providerContacted": {
      "type": "boolean",
      "const": false
    },
    "workerActivated": {
      "type": "boolean",
      "const": false
    }
  },
  "definitions": {
    "budgetResult": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "budgetId",
        "revision",
        "path",
        "status"
      ],
      "properties": {
        "budgetId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "revision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        },
        "path": {
          "type": "string",
          "minLength": 1,
          "maxLength": 500
        },
        "status": {
          "type": "string",
          "const": "paused"
        }
      }
    }
  }
} as const;
