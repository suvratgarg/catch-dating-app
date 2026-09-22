/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const upsertProgramPickupPointCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/upsert_program_pickup_point_payload.schema.json",
  "title": "UpsertProgramPickupPointCallablePayload",
  "description": "Create or update a program pickup station such as an airport terminal arrivals zone.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "programId",
    "kind",
    "label"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "pickupPointId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "kind": {
      "type": "string",
      "enum": [
        "airport",
        "railway",
        "venue",
        "other"
      ]
    },
    "label": {
      "type": "string",
      "minLength": 1,
      "maxLength": 140
    },
    "iataCode": {
      "anyOf": [
        {
          "type": "string",
          "pattern": "^[A-Z]{3}$"
        },
        {
          "type": "null"
        }
      ]
    },
    "terminal": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 40
    },
    "meetingZone": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 140
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
    "instructions": {
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
