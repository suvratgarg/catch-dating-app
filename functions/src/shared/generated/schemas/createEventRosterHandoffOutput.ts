/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const createEventRosterHandoffCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/create_event_roster_handoff_response.schema.json",
  "title": "CreateEventRosterHandoffCallableResponse",
  "description": "Provider-aware forwarding instructions for one event roster.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "expiresAtMillis",
    "emailStatus",
    "emailAlias",
    "whatsappStatus",
    "whatsappNumber",
    "whatsappMessage"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expiresAtMillis": {
      "type": "integer",
      "minimum": 0
    },
    "emailStatus": {
      "type": "string",
      "enum": [
        "available",
        "providerSetupRequired"
      ]
    },
    "emailAlias": {
      "anyOf": [
        {
          "type": "string",
          "format": "email",
          "maxLength": 320
        },
        {
          "type": "null"
        }
      ]
    },
    "whatsappStatus": {
      "type": "string",
      "enum": [
        "available",
        "providerSetupRequired"
      ]
    },
    "whatsappNumber": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^\\+[1-9][0-9]{6,14}$"
    },
    "whatsappMessage": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 20,
      "maxLength": 160
    }
  }
} as const;
