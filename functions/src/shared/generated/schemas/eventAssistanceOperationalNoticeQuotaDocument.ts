/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceOperationalNoticeQuotaDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_assistance_operational_notice_quotas.schema.json",
  "title": "EventAssistanceOperationalNoticeQuotaDocument",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "quotaId",
    "context",
    "eventId",
    "attendeeId",
    "attendeeGeneration",
    "sourceGeneration",
    "workflowKind",
    "count",
    "revision",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "quotaId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "context": {
      "anyOf": [
        {
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
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "mode",
            "rehearsalId",
            "virtualEventId",
            "clockId"
          ],
          "properties": {
            "mode": {
              "type": "string",
              "const": "rehearsal"
            },
            "rehearsalId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 2000
            },
            "virtualEventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "clockId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 2000
            }
          }
        }
      ]
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "attendeeId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "attendeeGeneration": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "sourceGeneration": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "workflowKind": {
      "type": "string",
      "enum": [
        "planChangeCommunication",
        "postEventFollowUp"
      ]
    },
    "count": {
      "type": "integer",
      "minimum": 0,
      "maximum": 10080
    },
    "revision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "createdAt": {
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
  "x-firestore-collection": "eventAssistanceOperationalNoticeQuotas",
  "x-firestore-path": "eventAssistanceOperationalNoticeQuotas/{quotaId}",
  "x-document-id-field": "quotaId",
  "x-owner": "trusted event-assistance operational notice publisher"
} as const;
