/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceCaseDocumentSchema: Record<string, unknown> = {
  "oneOf": [
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "schemaVersion",
        "caseId",
        "guestId",
        "context",
        "attendeeId",
        "episodeId",
        "responseId",
        "messageId",
        "status",
        "receivedAt",
        "category",
        "owner"
      ],
      "properties": {
        "schemaVersion": {
          "const": 1
        },
        "caseId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "guestId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
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
        "attendeeId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "episodeId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "responseId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "messageId": {
          "type": "string",
          "pattern": "^outbox:[a-f0-9]{64}$"
        },
        "status": {
          "enum": [
            "open",
            "resolved"
          ]
        },
        "receivedAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "category": {
          "enum": [
            "eventLogistics",
            "accessibility",
            "other"
          ]
        },
        "owner": {
          "const": "eventLead"
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "schemaVersion",
        "caseId",
        "guestId",
        "context",
        "attendeeId",
        "episodeId",
        "responseId",
        "messageId",
        "status",
        "receivedAt",
        "category",
        "owner"
      ],
      "properties": {
        "schemaVersion": {
          "const": 1
        },
        "caseId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "guestId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
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
        "attendeeId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "episodeId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "responseId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "messageId": {
          "type": "string",
          "pattern": "^outbox:[a-f0-9]{64}$"
        },
        "status": {
          "enum": [
            "open",
            "resolved"
          ]
        },
        "receivedAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "category": {
          "enum": [
            "comfortSafety"
          ]
        },
        "owner": {
          "const": "authorizedSafetyOperator"
        }
      }
    }
  ],
  "title": "EventAssistanceCaseDocument",
  "x-firestore-collection": "eventAssistanceCases",
  "x-firestore-path": "eventAssistanceCases/{caseId}",
  "x-document-id-field": "caseId",
  "x-owner": "trusted event-assistance guest boundary"
} as const;
