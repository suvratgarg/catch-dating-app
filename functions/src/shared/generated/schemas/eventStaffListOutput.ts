/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventStaffListCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/event_staff_list_response.schema.json",
  "title": "EventStaffListCallableResponse",
  "description": "Manager-only event staff list with masked phone data.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "members"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "members": {
      "type": "array",
      "maxItems": 50,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "uid",
          "displayName",
          "phoneLastFour",
          "status",
          "expiresAtMillis",
          "revision"
        ],
        "properties": {
          "uid": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "displayName": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
          },
          "phoneLastFour": {
            "type": "string",
            "pattern": "^[0-9]{4}$"
          },
          "status": {
            "type": "string",
            "enum": [
              "active",
              "revoked",
              "expired"
            ]
          },
          "expiresAtMillis": {
            "type": "integer",
            "minimum": 0
          },
          "revision": {
            "type": "integer",
            "minimum": 1,
            "maximum": 9007199254740991
          }
        }
      }
    }
  },
  "definitions": {
    "member": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "uid",
        "displayName",
        "phoneLastFour",
        "status",
        "expiresAtMillis",
        "revision"
      ],
      "properties": {
        "uid": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "displayName": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        "phoneLastFour": {
          "type": "string",
          "pattern": "^[0-9]{4}$"
        },
        "status": {
          "type": "string",
          "enum": [
            "active",
            "revoked",
            "expired"
          ]
        },
        "expiresAtMillis": {
          "type": "integer",
          "minimum": 0
        },
        "revision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        }
      }
    }
  }
} as const;
