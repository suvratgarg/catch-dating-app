/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const importOrganizerApplicationsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/import_organizer_applications_payload.schema.json",
  "title": "ImportOrganizerApplicationsCallablePayload",
  "description": "Commits a bounded provider-neutral tabular application import.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "formId",
    "formVersionId",
    "targetKind",
    "targetId",
    "mappingId",
    "importKey",
    "fileName",
    "format",
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
    "formId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "formVersionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "targetKind": {
      "type": "string",
      "enum": [
        "organizer",
        "event",
        "campaign"
      ]
    },
    "targetId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "mappingId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "importKey": {
      "type": "string",
      "minLength": 8,
      "maxLength": 120
    },
    "fileName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 255
    },
    "format": {
      "type": "string",
      "enum": [
        "csv",
        "xlsx",
        "connector"
      ]
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
  }
} as const;
