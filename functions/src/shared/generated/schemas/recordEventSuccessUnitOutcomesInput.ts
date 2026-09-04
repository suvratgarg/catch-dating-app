/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const recordEventSuccessUnitOutcomesCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/record_event_success_unit_outcomes_payload.schema.json",
  "title": "RecordEventSuccessUnitOutcomesCallablePayload",
  "description": "Revision-fenced Host payload that replaces one complete unit-outcome round.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "expectedRevision",
    "roundIndex",
    "entries"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 2147483647
    },
    "roundIndex": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100
    },
    "entries": {
      "type": "array",
      "minItems": 1,
      "maxItems": 200,
      "items": {
        "oneOf": [
          {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "unitId",
              "unitLabel",
              "completed"
            ],
            "properties": {
              "unitId": {
                "type": "string",
                "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$"
              },
              "unitLabel": {
                "type": "string",
                "minLength": 1,
                "maxLength": 80
              },
              "completed": {
                "type": "boolean"
              }
            }
          },
          {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "unitId",
              "unitLabel",
              "score"
            ],
            "properties": {
              "unitId": {
                "type": "string",
                "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$"
              },
              "unitLabel": {
                "type": "string",
                "minLength": 1,
                "maxLength": 80
              },
              "score": {
                "type": "number",
                "minimum": -1000000,
                "maximum": 1000000
              }
            }
          },
          {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "unitId",
              "unitLabel",
              "rank"
            ],
            "properties": {
              "unitId": {
                "type": "string",
                "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$"
              },
              "unitLabel": {
                "type": "string",
                "minLength": 1,
                "maxLength": 80
              },
              "rank": {
                "type": "integer",
                "minimum": 1,
                "maximum": 200
              }
            }
          }
        ]
      }
    }
  }
} as const;
