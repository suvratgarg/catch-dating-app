/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceCheckpointReceiptDocumentSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "receiptId",
    "requestHash",
    "report"
  ],
  "properties": {
    "receiptId": {
      "type": "string",
      "pattern": "^checkpoint-action:[a-f0-9]{64}$"
    },
    "requestHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "report": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "schemaVersion",
        "reportId",
        "context",
        "groupId",
        "checkpointId",
        "progressRevision",
        "rosterId",
        "rosterHash",
        "revision",
        "accountedFor",
        "reportedBy",
        "reportedAt",
        "correctionReason",
        "createdAt"
      ],
      "properties": {
        "schemaVersion": {
          "const": 1
        },
        "reportId": {
          "type": "string",
          "pattern": "^checkpoint:[a-f0-9]{64}$"
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
        "groupId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "checkpointId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 2000
        },
        "progressRevision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        },
        "rosterId": {
          "type": "string",
          "pattern": "^departure-roster:[a-f0-9]{64}$"
        },
        "rosterHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "revision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        },
        "accountedFor": {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          },
          "uniqueItems": true,
          "maxItems": 1000
        },
        "reportedBy": {
          "type": "string",
          "minLength": 1,
          "maxLength": 2000
        },
        "reportedAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "correctionReason": {
          "anyOf": [
            {
              "type": "string",
              "minLength": 1,
              "maxLength": 500,
              "pattern": "\\S"
            },
            {
              "type": "null"
            }
          ]
        },
        "createdAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        }
      }
    }
  },
  "title": "EventAssistanceCheckpointReceiptDocument",
  "x-firestore-collection": "eventAssistanceCheckpointReceipts",
  "x-firestore-path": "eventAssistanceCheckpointReceipts/{receiptId}",
  "x-document-id-field": "receiptId",
  "x-owner": "event-assistance checkpoint command"
} as const;
