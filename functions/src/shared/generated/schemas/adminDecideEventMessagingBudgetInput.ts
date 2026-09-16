/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminDecideEventMessagingBudgetCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_decide_event_messaging_budget_payload.schema.json",
  "title": "AdminDecideEventMessagingBudgetCallablePayload",
  "description": "Finance review decision for proposed event-messaging ceilings. The callable records evidence only and does not create, update, or activate a spending budget.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "requestId",
    "organizerId",
    "eventId",
    "routeId",
    "senderId",
    "purpose",
    "expectedRevision",
    "expectedRuntimeSourceHash",
    "expectedSenderReviewHash",
    "expectedBudgetSourceHash",
    "decision",
    "note"
  ],
  "properties": {
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
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
    "expectedRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "expectedRuntimeSourceHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "expectedSenderReviewHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "expectedBudgetSourceHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
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
    "note": {
      "type": "string",
      "minLength": 1,
      "maxLength": 1000
    }
  },
  "definitions": {
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
    }
  }
} as const;
