/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const previewOrganizerApplicationImportCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/preview_organizer_application_import_payload.schema.json",
  "title": "PreviewOrganizerApplicationImportCallablePayload",
  "description": "Provider-neutral tabular application preview after local CSV or XLSX decoding.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "formVersionId",
    "headers",
    "mappings",
    "rows"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "formVersionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "headers": {
      "type": "array",
      "minItems": 1,
      "maxItems": 100,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 240
      }
    },
    "mappings": {
      "type": "array",
      "maxItems": 100,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "headerIndex",
          "questionId",
          "transform"
        ],
        "properties": {
          "headerIndex": {
            "type": "integer",
            "minimum": 0,
            "maximum": 99
          },
          "questionId": {
            "type": [
              "string",
              "null"
            ],
            "minLength": 1,
            "maxLength": 120
          },
          "transform": {
            "type": "string",
            "enum": [
              "identity",
              "trim",
              "e164",
              "isoDate",
              "number",
              "boolean",
              "splitOptions",
              "assetUrl"
            ]
          }
        }
      }
    },
    "rows": {
      "type": "array",
      "minItems": 1,
      "maxItems": 200,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "rowId",
          "values"
        ],
        "properties": {
          "rowId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
          },
          "values": {
            "type": "array",
            "minItems": 1,
            "maxItems": 100,
            "items": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 4000
            }
          }
        }
      }
    }
  },
  "definitions": {
    "headers": {
      "type": "array",
      "minItems": 1,
      "maxItems": 100,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 240
      }
    },
    "mappings": {
      "type": "array",
      "maxItems": 100,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "headerIndex",
          "questionId",
          "transform"
        ],
        "properties": {
          "headerIndex": {
            "type": "integer",
            "minimum": 0,
            "maximum": 99
          },
          "questionId": {
            "type": [
              "string",
              "null"
            ],
            "minLength": 1,
            "maxLength": 120
          },
          "transform": {
            "type": "string",
            "enum": [
              "identity",
              "trim",
              "e164",
              "isoDate",
              "number",
              "boolean",
              "splitOptions",
              "assetUrl"
            ]
          }
        }
      }
    },
    "rows": {
      "type": "array",
      "minItems": 1,
      "maxItems": 200,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "rowId",
          "values"
        ],
        "properties": {
          "rowId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
          },
          "values": {
            "type": "array",
            "minItems": 1,
            "maxItems": 100,
            "items": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 4000
            }
          }
        }
      }
    }
  }
} as const;
