/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listEventAssistanceDeliveriesCallablePayloadSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "context",
    "cursor"
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
    "cursor": {
      "anyOf": [
        {
          "type": "string",
          "pattern": "^outbox:[a-f0-9]{64}$"
        },
        {
          "type": "null"
        }
      ]
    }
  },
  "title": "ListEventAssistanceDeliveriesCallablePayload"
} as const;
