/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programStationScopeCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/program_station_scope_payload.schema.json",
  "title": "ProgramStationScopeCallablePayload",
  "description": "Pickup-station scoped program read shared by the arrivals roster and transport plan callables.",
  "type": "object",
  "additionalProperties": false,
  "x-callable-aliases": [
    "getProgramArrivalsRoster",
    "getProgramTransportPlan"
  ],
  "required": [
    "programId"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "pickupPointId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180,
      "description": "Requested station. Staff are still intersected with their granted station scope; managers may read any station."
    }
  }
} as const;
