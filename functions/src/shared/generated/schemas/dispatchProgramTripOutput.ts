/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const dispatchProgramTripCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/dispatch_program_trip_response.schema.json",
  "title": "DispatchProgramTripCallableResponse",
  "description": "Committed dispatch result; an exact replay returns the original trip id and revision.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "tripId",
    "revision",
    "alreadyApplied",
    "passengerCount"
  ],
  "properties": {
    "tripId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "alreadyApplied": {
      "type": "boolean"
    },
    "passengerCount": {
      "type": "integer",
      "minimum": 1,
      "maximum": 200
    }
  }
} as const;
