/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventMessagingBudgetDecisionDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_messaging_budget_decisions.schema.json",
  "title": "EventMessagingBudgetDecisionDocument",
  "description": "Latest finance review decision for one event, route, sender, and purpose. This record grants no spending authority and is not a dispatch budget.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventMessagingBudgetDecisions",
  "x-firestore-path": "eventMessagingBudgetDecisions/{decisionId}",
  "x-document-id-field": "decisionId",
  "x-owner": "adminDecideEventMessagingBudget callable",
  "required": [
    "schemaVersion",
    "decisionId",
    "revision",
    "requestId",
    "requestHash",
    "context",
    "routeId",
    "senderId",
    "purpose",
    "decision",
    "decisionStatus",
    "reviewEvidence",
    "reviewedByUid",
    "note",
    "createdAt",
    "updatedAt",
    "effect",
    "grantsSpendingAuthority"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
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
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "requestHash": {
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
    "decision": {
      "oneOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "currency",
            "eventLimitMicros",
            "senderDayLimitMicros",
            "validUntil"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "approve"
            },
            "currency": {
              "type": "string",
              "pattern": "^[A-Z]{3}$"
            },
            "eventLimitMicros": {
              "type": "integer",
              "minimum": 1,
              "maximum": 9007199254740991
            },
            "senderDayLimitMicros": {
              "type": "integer",
              "minimum": 1,
              "maximum": 9007199254740991
            },
            "validUntil": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "hold"
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "reject"
            }
          }
        }
      ]
    },
    "decisionStatus": {
      "type": "string",
      "enum": [
        "approved",
        "held",
        "rejected"
      ]
    },
    "reviewEvidence": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "observedAt",
        "completedAt",
        "eventEnd",
        "runtimeSourceHash",
        "senderReviewHash",
        "budgetSourceHash",
        "setupReviewHash",
        "eventBudget",
        "senderDayBudget"
      ],
      "properties": {
        "observedAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "completedAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "eventEnd": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "runtimeSourceHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "senderReviewHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "budgetSourceHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "setupReviewHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "eventBudget": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "budgetId",
            "revision",
            "reviewHash",
            "chargedMicros"
          ],
          "properties": {
            "budgetId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "revision": {
              "type": [
                "integer",
                "null"
              ],
              "minimum": 1,
              "maximum": 9007199254740991
            },
            "reviewHash": {
              "anyOf": [
                {
                  "type": "string",
                  "pattern": "^[a-f0-9]{64}$"
                },
                {
                  "type": "null"
                }
              ]
            },
            "chargedMicros": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            }
          }
        },
        "senderDayBudget": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "budgetId",
            "revision",
            "reviewHash",
            "chargedMicros"
          ],
          "properties": {
            "budgetId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "revision": {
              "type": [
                "integer",
                "null"
              ],
              "minimum": 1,
              "maximum": 9007199254740991
            },
            "reviewHash": {
              "anyOf": [
                {
                  "type": "string",
                  "pattern": "^[a-f0-9]{64}$"
                },
                {
                  "type": "null"
                }
              ]
            },
            "chargedMicros": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            }
          }
        }
      }
    },
    "reviewedByUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "note": {
      "type": "string",
      "minLength": 1,
      "maxLength": 1000
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
    },
    "updatedAt": {
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
    },
    "effect": {
      "type": "string",
      "const": "decision_only_no_spending_authority"
    },
    "grantsSpendingAuthority": {
      "type": "boolean",
      "const": false
    }
  },
  "definitions": {
    "budgetEvidence": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "budgetId",
        "revision",
        "reviewHash",
        "chargedMicros"
      ],
      "properties": {
        "budgetId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "revision": {
          "type": [
            "integer",
            "null"
          ],
          "minimum": 1,
          "maximum": 9007199254740991
        },
        "reviewHash": {
          "anyOf": [
            {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            {
              "type": "null"
            }
          ]
        },
        "chargedMicros": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        }
      }
    }
  }
} as const;
