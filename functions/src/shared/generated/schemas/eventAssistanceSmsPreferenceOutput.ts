/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceSmsPreferenceCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/event_assistance_sms_preference_response.schema.json",
  "title": "EventAssistanceSmsPreferenceCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "outcome",
    "view"
  ],
  "properties": {
    "outcome": {
      "type": "string",
      "enum": [
        "read",
        "applied",
        "replayed",
        "conflict"
      ]
    },
    "view": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "eventId",
        "attendeeId",
        "serverTime",
        "revision",
        "preference",
        "canEnable",
        "availability",
        "phoneLastFour",
        "expiresAt",
        "consent"
      ],
      "properties": {
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
        "serverTime": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "revision": {
          "anyOf": [
            {
              "type": "null"
            },
            {
              "type": "integer",
              "minimum": 1,
              "maximum": 9007199254740991
            }
          ]
        },
        "preference": {
          "type": "string",
          "enum": [
            "notSet",
            "enabled",
            "disabled",
            "expired"
          ]
        },
        "canEnable": {
          "type": "boolean"
        },
        "availability": {
          "type": "string",
          "enum": [
            "ready",
            "senderUnavailable",
            "eventClosed",
            "notAdmitted",
            "verifyPhone"
          ]
        },
        "phoneLastFour": {
          "anyOf": [
            {
              "type": "null"
            },
            {
              "type": "string",
              "pattern": "^[0-9]{4}$"
            }
          ]
        },
        "expiresAt": {
          "anyOf": [
            {
              "type": "null"
            },
            {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            }
          ]
        },
        "consent": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "version",
            "text"
          ],
          "properties": {
            "version": {
              "type": "string",
              "const": "catch-event-service-sms-v1"
            },
            "text": {
              "type": "string",
              "minLength": 1,
              "maxLength": 500
            }
          }
        }
      }
    }
  }
} as const;
