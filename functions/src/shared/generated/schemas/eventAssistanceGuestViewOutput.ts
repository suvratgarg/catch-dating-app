/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceGuestViewCallableResponseSchema: Record<string, unknown> = {
  "oneOf": [
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "status",
        "serverTime",
        "reason"
      ],
      "properties": {
        "status": {
          "const": "unavailable"
        },
        "serverTime": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "reason": {
          "enum": [
            "expired",
            "eventClosed",
            "guestUnavailable",
            "noInstructions",
            "alreadyJoined"
          ]
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "status",
        "serverTime",
        "eventTitle",
        "guestRevision",
        "intentId",
        "intentRevision",
        "instructionRevision",
        "title",
        "text",
        "expiresAt",
        "response",
        "choices"
      ],
      "properties": {
        "status": {
          "const": "ready"
        },
        "serverTime": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "eventTitle": {
          "type": "string",
          "maxLength": 160
        },
        "guestRevision": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "intentId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "intentRevision": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "instructionRevision": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "title": {
          "type": "string",
          "maxLength": 120
        },
        "text": {
          "type": "string",
          "maxLength": 2000
        },
        "expiresAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "response": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "label",
                "receivedAt"
              ],
              "properties": {
                "label": {
                  "type": "string",
                  "maxLength": 80
                },
                "receivedAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                }
              }
            },
            {
              "type": "null"
            }
          ]
        },
        "choices": {
          "type": "array",
          "maxItems": 20,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "choiceId",
              "label"
            ],
            "properties": {
              "choiceId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160,
                "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
              },
              "label": {
                "type": "string",
                "minLength": 1,
                "maxLength": 80
              }
            }
          }
        }
      }
    }
  ],
  "title": "EventAssistanceGuestViewCallableResponse"
} as const;
