/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const refreshProgramTravelLegCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/refresh_program_travel_leg_payload.schema.json",
  "title": "RefreshProgramTravelLegCallablePayload",
  "description": "Manual flight-status refresh for a single travel leg; any active program staff member may request it.",
  "type": "object",
  "additionalProperties": false,
  "x-callable-aliases": [
    "refreshProgramTravelLeg"
  ],
  "required": [
    "programId",
    "legId"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "legId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
