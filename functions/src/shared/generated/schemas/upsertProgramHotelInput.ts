/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const upsertProgramHotelCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/upsert_program_hotel_payload.schema.json",
  "title": "UpsertProgramHotelCallablePayload",
  "description": "Create or update a program accommodation property.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "programId",
    "name",
    "address"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "hotelId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "name": {
      "type": "string",
      "minLength": 1,
      "maxLength": 140
    },
    "address": {
      "type": "string",
      "minLength": 1,
      "maxLength": 300
    },
    "latitude": {
      "type": [
        "number",
        "null"
      ],
      "minimum": -90,
      "maximum": 90
    },
    "longitude": {
      "type": [
        "number",
        "null"
      ],
      "minimum": -180,
      "maximum": 180
    },
    "receptionContact": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 140
    },
    "notes": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 500
    },
    "active": {
      "type": "boolean"
    }
  }
} as const;
