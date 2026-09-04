/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventOperatorAccessCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/event_operator_access_response.schema.json",
  "title": "EventOperatorAccessCallableResponse",
  "description": "Sanitized event facts and exact operator permissions. No organizer-wide data is exposed.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "organizerId",
    "title",
    "startAtMillis",
    "endAtMillis",
    "eventStatus",
    "actorRole",
    "permissions",
    "grantExpiresAtMillis"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "title": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160
    },
    "startAtMillis": {
      "type": "integer",
      "minimum": 0
    },
    "endAtMillis": {
      "type": "integer",
      "minimum": 0
    },
    "eventStatus": {
      "type": "string",
      "enum": [
        "active",
        "cancelled"
      ]
    },
    "actorRole": {
      "type": "string",
      "enum": [
        "manager",
        "operator"
      ]
    },
    "permissions": {
      "type": "array",
      "minItems": 1,
      "maxItems": 4,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "enum": [
          "viewRoster",
          "setAttendance",
          "reviewRuntimeClaims",
          "publishLiveLocation"
        ]
      }
    },
    "grantExpiresAtMillis": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 0
    }
  }
} as const;
