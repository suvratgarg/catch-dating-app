/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceOperationalNoticeFanoutSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/operations/event_assistance_operational_notice_fanout.schema.json",
  "title": "EventAssistanceOperationalNoticeFanout",
  "description": "Private bounded attendee fanout for one trusted plan-change or post-event source. The work binds a reviewed policy revision and grants no provider authority by itself.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "kind",
    "signalId",
    "context",
    "source",
    "policyBinding",
    "expiresAt",
    "checkpoint"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "kind": {
      "type": "string",
      "const": "operationalNoticeFanout"
    },
    "signalId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
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
    "source": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "kind",
        "sourceId",
        "revision",
        "occurredAt",
        "validUntil"
      ],
      "properties": {
        "kind": {
          "type": "string",
          "enum": [
            "planChange",
            "followUp"
          ]
        },
        "sourceId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "revision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        },
        "occurredAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "validUntil": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        }
      }
    },
    "policyBinding": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "groupId",
        "workflowKind",
        "settingId",
        "settingRevision"
      ],
      "properties": {
        "groupId": {
          "type": "string",
          "const": "event:whole"
        },
        "workflowKind": {
          "type": "string",
          "enum": [
            "planChangeCommunication",
            "postEventFollowUp"
          ]
        },
        "settingId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "settingRevision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        }
      }
    },
    "expiresAt": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "checkpoint": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "phase",
        "cursor",
        "visited",
        "published",
        "skipped",
        "dueAt",
        "failures",
        "retries",
        "stopReason"
      ],
      "properties": {
        "phase": {
          "type": "string",
          "enum": [
            "scan",
            "retry",
            "complete",
            "review",
            "expired",
            "stopped"
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
        "published": {
          "type": "integer",
          "minimum": 0,
          "maximum": 10000
        },
        "skipped": {
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
              "attendeeId",
              "reason"
            ],
            "properties": {
              "attendeeId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 180,
                "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
              },
              "reason": {
                "type": "string",
                "enum": [
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
        },
        "stopReason": {
          "enum": [
            null,
            "policyUnavailable",
            "policyChanged",
            "sourceChanged"
          ]
        }
      }
    }
  }
} as const;
