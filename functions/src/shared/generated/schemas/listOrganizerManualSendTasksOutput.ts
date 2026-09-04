/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listOrganizerManualSendTasksCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/list_organizer_manual_send_tasks_response.schema.json",
  "title": "ListOrganizerManualSendTasksCallableResponse",
  "description": "Bounded manual-send queue or history page.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "tasks",
    "nextCursor"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "tasks": {
      "type": "array",
      "maxItems": 50,
      "items": {
        "title": "OrganizerManualSendTaskCallableResponse",
        "description": "Manager-visible manual handoff task. Handoff-opened and host-marked-sent are assertions, never delivery receipts.",
        "type": "object",
        "additionalProperties": false,
        "required": [
          "organizerId",
          "taskId",
          "contactId",
          "displayName",
          "intent",
          "routeId",
          "deliveryMode",
          "status",
          "active",
          "revision",
          "phoneE164",
          "prefillText",
          "openCount",
          "createdAtMillis",
          "updatedAtMillis",
          "openedAtMillis",
          "expiresAtMillis"
        ],
        "properties": {
          "organizerId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "taskId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "contactId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "displayName": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
          },
          "intent": {
            "type": "string",
            "enum": [
              "individualConversation",
              "savedAudienceCampaign"
            ]
          },
          "routeId": {
            "const": "personalWhatsappHandoff"
          },
          "deliveryMode": {
            "const": "byHand"
          },
          "status": {
            "type": "string",
            "enum": [
              "queued",
              "handoffOpened",
              "hostMarkedSent",
              "skipped",
              "cancelled",
              "superseded",
              "expired"
            ]
          },
          "active": {
            "type": "boolean"
          },
          "revision": {
            "type": "integer",
            "minimum": 1,
            "maximum": 9007199254740991
          },
          "phoneE164": {
            "type": "string",
            "pattern": "^\\+[1-9][0-9]{7,14}$"
          },
          "prefillText": {
            "type": "string",
            "minLength": 1,
            "maxLength": 1000
          },
          "openCount": {
            "type": "integer",
            "minimum": 0,
            "maximum": 1000
          },
          "createdAtMillis": {
            "type": "integer",
            "minimum": 0
          },
          "updatedAtMillis": {
            "type": "integer",
            "minimum": 0
          },
          "openedAtMillis": {
            "type": [
              "integer",
              "null"
            ],
            "minimum": 0
          },
          "expiresAtMillis": {
            "type": "integer",
            "minimum": 0
          }
        }
      }
    },
    "nextCursor": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 1000
    }
  }
} as const;
