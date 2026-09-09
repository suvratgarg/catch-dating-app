/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceSmsBudgetDocumentSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "budgetId",
    "revision",
    "senderId",
    "scope",
    "status",
    "approvalId",
    "currency",
    "limitMicros",
    "chargedMicros",
    "startsAt",
    "endsAt",
    "updatedAt"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
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
    "senderId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "scope": {
      "oneOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "context"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "event"
            },
            "context": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode",
                "organizerId",
                "eventId"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "live"
                },
                "organizerId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                }
              }
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "day"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "senderDay"
            },
            "day": {
              "type": "string",
              "pattern": "^\\d{4}-\\d{2}-\\d{2}$"
            }
          }
        }
      ]
    },
    "status": {
      "type": "string",
      "enum": [
        "active",
        "paused"
      ]
    },
    "approvalId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "currency": {
      "type": "string",
      "const": "INR"
    },
    "limitMicros": {
      "type": "integer",
      "minimum": 0,
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
    "updatedAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    }
  },
  "title": "EventAssistanceSmsBudgetDocument",
  "x-firestore-collection": "eventAssistanceSmsBudgets",
  "x-firestore-path": "eventAssistanceSmsBudgets/{budgetId}",
  "x-document-id-field": "budgetId",
  "x-owner": "trusted event-assistance SMS worker"
} as const;
