/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const setEventAssistanceSmsPreferenceCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/set_event_assistance_sms_preference_payload.schema.json",
  "title": "SetEventAssistanceSmsPreferenceCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "attendeeId",
    "requestId",
    "expectedRevision",
    "decision"
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
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "expectedRevision": {
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
    "decision": {
      "oneOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "copyVersion"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "grant"
            },
            "copyVersion": {
              "type": "string",
              "const": "catch-event-service-sms-v1"
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
              "const": "revoke"
            }
          }
        }
      ]
    }
  }
} as const;
