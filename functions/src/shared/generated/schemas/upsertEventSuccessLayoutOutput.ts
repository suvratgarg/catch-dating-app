/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const upsertEventSuccessLayoutCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/upsert_event_success_layout_response.schema.json",
  "title": "UpsertEventSuccessLayoutCallableResponse",
  "description": "Canonical saved organizer layout returned after an upsert.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "layout"
  ],
  "properties": {
    "layout": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "layoutId",
        "label",
        "units"
      ],
      "properties": {
        "layoutId": {
          "type": "string",
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
    }
  }
} as const;
