/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceSourceWorkSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/operations/event_assistance_source_work.schema.json",
  "title": "EventAssistanceSourceWork",
  "description": "Private bounded source-change fanout using Operations work items. Waking work grants no domain or provider authority.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "kind",
    "signalId",
    "source",
    "scope",
    "expiresAt",
    "checkpoint"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1,
      "type": "integer"
    },
    "kind": {
      "const": "liveSourceWake",
      "type": "string"
    },
    "signalId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "source": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "eventId",
        "collection",
        "documentId",
        "occurredAt"
      ],
      "properties": {
        "eventId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "collection": {
          "type": "string",
          "enum": [
            "events",
            "eventAttendees",
            "eventSuccessPlans",
            "eventAssistanceGuests",
            "eventAssistanceSettings",
            "eventAssistanceGroupProgress",
            "eventAssistanceMemberships",
            "eventAssistanceMessages",
            "eventAssistanceRuntimeConfigs",
            "eventAssistanceSmsPermissions",
            "eventAssistanceWhatsappPermissions"
          ]
        },
        "documentId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "occurredAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        }
      }
    },
    "scope": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "context",
        "attendeeId"
      ],
      "properties": {
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
          "anyOf": [
            {
              "type": "string",
              "minLength": 1,
              "maxLength": 180,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            {
              "type": "null"
            }
          ]
        }
      }
    },
    "expiresAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "checkpoint": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "phase",
        "cursor",
        "visited",
        "dueAt",
        "failures",
        "retries"
      ],
      "properties": {
        "phase": {
          "type": "string",
          "enum": [
            "scan",
            "retry",
            "complete",
            "review",
            "expired"
          ]
        },
        "cursor": {
          "anyOf": [
            {
              "type": "string",
              "minLength": 1,
              "maxLength": 180,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            {
              "type": "null"
            }
          ]
        },
        "visited": {
          "type": "integer",
          "minimum": 0,
          "maximum": 10000
        },
        "dueAt": {
          "anyOf": [
            {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            {
              "type": "null"
            }
          ]
        },
        "failures": {
          "type": "array",
          "maxItems": 100,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "workItemId",
              "reason"
            ],
            "properties": {
              "workItemId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 180,
                "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
              },
              "reason": {
                "type": "string",
                "enum": [
                  "busy",
                  "unavailable"
                ]
              }
            }
          }
        },
        "retries": {
          "type": "integer",
          "minimum": 0,
          "maximum": 5
        }
      }
    }
  }
} as const;
