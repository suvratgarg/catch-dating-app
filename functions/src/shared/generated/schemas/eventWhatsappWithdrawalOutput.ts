/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventWhatsappWithdrawalCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/event_whatsapp_withdrawal_response.schema.json",
  "title": "EventWhatsappWithdrawalCallableResponse",
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
        "serverTime",
        "revision",
        "preference",
        "expiresAt"
      ],
      "properties": {
        "serverTime": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "revision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        },
        "preference": {
          "type": "string",
          "enum": [
            "enabled",
            "disabled",
            "expired"
          ]
        },
        "expiresAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        }
      }
    }
  }
} as const;
