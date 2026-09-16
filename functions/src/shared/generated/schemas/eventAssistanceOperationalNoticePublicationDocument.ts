/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceOperationalNoticePublicationDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_assistance_operational_notice_publications.schema.json",
  "title": "EventAssistanceOperationalNoticePublicationDocument",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "publicationId",
    "quotaId",
    "context",
    "eventId",
    "attendeeId",
    "episodeId",
    "sourceKind",
    "workflowKind",
    "sourceId",
    "sourceRevision",
    "messageId",
    "threadId",
    "ordinal",
    "contentHash",
    "intentHash",
    "sourceOccurredAt",
    "createdAt"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "publicationId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
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
    "episodeId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "sourceKind": {
      "type": "string",
      "enum": [
        "planChange",
        "followUp"
      ]
    },
    "workflowKind": {
      "type": "string",
      "enum": [
        "planChangeCommunication",
        "postEventFollowUp"
      ]
    },
    "sourceId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "sourceRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "messageId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "threadId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "ordinal": {
      "type": "integer",
      "minimum": 1,
      "maximum": 10080
    },
    "contentHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "intentHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "sourceOccurredAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "createdAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    }
  },
  "x-firestore-collection": "eventAssistanceOperationalNoticePublications",
  "x-firestore-path": "eventAssistanceOperationalNoticePublications/{publicationId}",
  "x-document-id-field": "publicationId",
  "x-owner": "trusted event-assistance operational notice publisher"
} as const;
