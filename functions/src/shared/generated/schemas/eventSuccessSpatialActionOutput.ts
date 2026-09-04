/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventSuccessSpatialActionCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/event_success_spatial_action_response.schema.json",
  "title": "EventSuccessSpatialActionCallableResponse",
  "description": "Current revision and optional destination validation for a Host spatial action.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "revision",
    "destinations"
  ],
  "properties": {
    "revision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 2147483647
    },
    "destinations": {
      "type": "array",
      "maxItems": 200,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "unitId",
          "valid",
          "reason",
          "recommendedScope"
        ],
        "properties": {
          "unitId": {
            "type": "string",
            "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{0,79}$"
          },
          "valid": {
            "type": "boolean"
          },
          "reason": {
            "type": [
              "string",
              "null"
            ],
            "enum": [
              "capacity",
              "safetyKeepApart",
              "declaredConstraint",
              null
            ]
          },
          "recommendedScope": {
            "type": [
              "string",
              "null"
            ],
            "enum": [
              "thisRound",
              "pinned",
              null
            ]
          }
        }
      }
    }
  }
} as const;
