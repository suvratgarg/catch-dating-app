/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const recordEventSuccessUnitOutcomesCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/record_event_success_unit_outcomes_response.schema.json",
  "title": "RecordEventSuccessUnitOutcomesCallableResponse",
  "description": "Persisted outcome revision and standings projection state.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "replayed",
    "revision",
    "standingCount"
  ],
  "properties": {
    "replayed": {
      "type": "boolean"
    },
    "revision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 2147483647
    },
    "standingCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 200
    }
  }
} as const;
