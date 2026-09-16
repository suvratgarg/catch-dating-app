/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventMessagingBudgetApplicationReceiptDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_messaging_budget_application_receipts.schema.json",
  "title": "EventMessagingBudgetApplicationReceiptDocument",
  "description": "Immutable evidence that one still-current approved decision staged both channel spending ceilings in paused state. The receipt and budgets grant no spending or dispatch authority until a separate live activation boundary succeeds.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventMessagingBudgetApplicationReceipts",
  "x-firestore-path": "eventMessagingBudgetApplicationReceipts/{receiptId}",
  "x-document-id-field": "receiptId",
  "x-owner": "adminApplyEventMessagingBudget callable",
  "required": [
    "schemaVersion",
    "receiptId",
    "requestId",
    "requestHash",
    "decisionId",
    "decisionRevision",
    "decisionReviewHash",
    "context",
    "routeId",
    "senderId",
    "purpose",
    "budgetSourceHash",
    "eventBudget",
    "senderDayBudget",
    "appliedByUid",
    "note",
    "effect",
    "stagesSpendingCeilings",
    "grantsSpendingAuthority",
    "grantsDispatchAuthority",
    "providerContacted",
    "workerActivated",
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
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "requestHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
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
    "decisionReviewHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
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
    "routeId": {
      "type": "string",
      "enum": [
        "catchEventSms",
        "catchEventRcs",
        "organizerEventWhatsapp"
      ]
    },
    "senderId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "purpose": {
      "type": "string",
      "enum": [
        "joiningUpdate",
        "joiningInstructions",
        "planChanged",
        "eventCancelled",
        "eventFinished",
        "guestRequirement",
        "assignmentChanged",
        "participationCheck",
        "followUp"
      ]
    },
    "budgetSourceHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "eventBudget": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "budgetId",
        "path",
        "revision",
        "currency",
        "limitMicros",
        "chargedMicros",
        "startsAt",
        "endsAt",
        "reviewHash",
        "status"
      ],
      "properties": {
        "budgetId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "path": {
          "type": "string",
          "minLength": 1,
          "maxLength": 500
        },
        "revision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        },
        "currency": {
          "type": "string",
          "pattern": "^[A-Z]{3}$"
        },
        "limitMicros": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        },
        "chargedMicros": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "startsAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "endsAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "reviewHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
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
        "path",
        "revision",
        "currency",
        "limitMicros",
        "chargedMicros",
        "startsAt",
        "endsAt",
        "reviewHash",
        "status"
      ],
      "properties": {
        "budgetId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "path": {
          "type": "string",
          "minLength": 1,
          "maxLength": 500
        },
        "revision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        },
        "currency": {
          "type": "string",
          "pattern": "^[A-Z]{3}$"
        },
        "limitMicros": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        },
        "chargedMicros": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "startsAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "endsAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "reviewHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "status": {
          "type": "string",
          "const": "paused"
        }
      }
    },
    "appliedByUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "note": {
      "type": "string",
      "minLength": 1,
      "maxLength": 1000
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
  },
  "definitions": {
    "budgetEvidence": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "budgetId",
        "path",
        "revision",
        "currency",
        "limitMicros",
        "chargedMicros",
        "startsAt",
        "endsAt",
        "reviewHash",
        "status"
      ],
      "properties": {
        "budgetId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "path": {
          "type": "string",
          "minLength": 1,
          "maxLength": 500
        },
        "revision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        },
        "currency": {
          "type": "string",
          "pattern": "^[A-Z]{3}$"
        },
        "limitMicros": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        },
        "chargedMicros": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "startsAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "endsAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "reviewHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "status": {
          "type": "string",
          "const": "paused"
        }
      }
    }
  }
} as const;
