/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const requestOrganizerFormExportCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/request_organizer_form_export_payload.schema.json",
  "title": "RequestOrganizerFormExportCallablePayload",
  "description": "Idempotent response export request or status refresh.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "formId",
    "requestId",
    "format",
    "statuses",
    "versionId",
    "fromMillis",
    "toMillis"
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
    "requestId": {
      "type": "string",
      "minLength": 8,
      "maxLength": 128
    },
    "format": {
      "type": "string",
      "enum": [
        "csv",
        "xlsx"
      ]
    },
    "statuses": {
      "type": "array",
      "minItems": 1,
      "maxItems": 2,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "enum": [
          "submitted",
          "withdrawn"
        ]
      }
    },
    "versionId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    },
    "fromMillis": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "toMillis": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 0,
      "maximum": 9007199254740991
    }
  }
} as const;
