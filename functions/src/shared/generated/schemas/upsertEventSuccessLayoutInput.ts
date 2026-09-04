/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const upsertEventSuccessLayoutCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/upsert_event_success_layout_payload.schema.json",
  "title": "UpsertEventSuccessLayoutCallablePayload",
  "description": "Creates or updates one reusable organizer-owned parametric layout.",
  "x-callable-aliases": [
    "upsertEventSuccessLayout"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "label",
    "units"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "layoutId": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$"
    },
    "label": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "units": {
      "type": "array",
      "minItems": 1,
      "maxItems": 200,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "id",
          "label",
          "shape",
          "capacity",
          "gridX",
          "gridY",
          "order"
        ],
        "properties": {
          "id": {
            "type": "string",
            "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{0,79}$"
          },
          "label": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "shape": {
            "type": "string",
            "enum": [
              "round",
              "rect",
              "row",
              "court",
              "zone"
            ]
          },
          "capacity": {
            "type": "integer",
            "minimum": 1,
            "maximum": 1000
          },
          "gridX": {
            "type": "integer",
            "minimum": 0,
            "maximum": 199
          },
          "gridY": {
            "type": "integer",
            "minimum": 0,
            "maximum": 199
          },
          "order": {
            "type": "integer",
            "minimum": 1,
            "maximum": 200
          }
        }
      }
    }
  }
} as const;
