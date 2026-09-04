/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const importOrganizerApplicationsCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/import_organizer_applications_response.schema.json",
  "title": "ImportOrganizerApplicationsCallableResponse",
  "description": "Result receipt for a committed organizer application import.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "receiptId",
    "status",
    "rowCount",
    "createdCount",
    "skippedCount",
    "errors",
    "replayed"
  ],
  "properties": {
    "receiptId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "status": {
      "type": "string",
      "enum": [
        "completed",
        "partial",
        "failed"
      ]
    },
    "rowCount": {
      "type": "integer",
      "minimum": 1,
      "maximum": 200
    },
    "createdCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 200
    },
    "skippedCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 200
    },
    "errors": {
      "type": "array",
      "maxItems": 100,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "rowId",
          "code",
          "message"
        ],
        "properties": {
          "rowId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
          },
          "code": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "message": {
            "type": "string",
            "minLength": 1,
            "maxLength": 240
          }
        }
      }
    },
    "replayed": {
      "type": "boolean"
    }
  }
} as const;
