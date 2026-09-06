/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const setEventWhatsappPreferenceCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/set_event_whatsapp_preference_payload.schema.json",
  "title": "SetEventWhatsappPreferenceCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "attendeeId",
    "requestId",
    "expectedRevision",
    "decision",
    "senderId"
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
            "copyVersion",
            "senderHash"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "grant"
            },
            "copyVersion": {
              "type": "string",
              "const": "catch-event-service-whatsapp-v1"
            },
            "senderHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
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
    },
    "senderId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    }
  }
} as const;
