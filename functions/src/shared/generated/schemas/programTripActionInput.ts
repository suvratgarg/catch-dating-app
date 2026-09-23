/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programTripActionCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/program_trip_action_payload.schema.json",
  "title": "ProgramTripActionCallablePayload",
  "description": "Post-dispatch trip lifecycle payload shared by markProgramTripArrived and voidProgramTrip; the callable name carries the action.",
  "type": "object",
  "additionalProperties": false,
  "x-callable-aliases": [
    "markProgramTripArrived",
    "voidProgramTrip"
  ],
  "required": [
    "programId",
    "tripId",
    "expectedRevision",
    "clientOperationId"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "tripId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "reason": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 280,
      "description": "Required for voidProgramTrip; recorded on the trip for reconciliation review."
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "clientOperationId": {
      "type": "string",
      "minLength": 8,
      "maxLength": 120
    }
  }
} as const;
