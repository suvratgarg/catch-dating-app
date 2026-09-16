/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceDepartureRosterCallableResponseSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "context",
    "groupId",
    "serverTime",
    "progressRevision",
    "selection"
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
    "groupId": {
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
    "progressRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "selection": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "attendeeIds",
        "expectedSourceHash"
      ],
      "properties": {
        "attendeeIds": {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          },
          "uniqueItems": true,
          "maxItems": 1000
        },
        "expectedSourceHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        }
      }
    }
  },
  "title": "EventAssistanceDepartureRosterCallableResponse"
} as const;
