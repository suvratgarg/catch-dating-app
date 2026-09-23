/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listProgramTripsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/list_program_trips_payload.schema.json",
  "title": "ListProgramTripsCallablePayload",
  "description": "Scoped trip ledger page, ordered by departure time descending.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "programId"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "limit": {
      "type": "integer",
      "minimum": 1,
      "maximum": 50
    },
    "cursor": {
      "type": "string",
      "maxLength": 180,
      "description": "Opaque cursor returned by the previous page.",
      "minLength": 1,
      "pattern": "^[^/]+$"
    }
  }
} as const;
