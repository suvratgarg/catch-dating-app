/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const requestOrganizerFormExportCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/request_organizer_form_export_response.schema.json",
  "title": "RequestOrganizerFormExportCallableResponse",
  "description": "Asynchronous export status and expiring download when complete.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "exportId",
    "status",
    "format",
    "rowCount",
    "downloadUrl",
    "expiresAtMillis",
    "errorMessage"
  ],
  "properties": {
    "exportId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "status": {
      "type": "string",
      "enum": [
        "pending",
        "running",
        "completed",
        "failed",
        "expired"
      ]
    },
    "format": {
      "type": "string",
      "enum": [
        "csv",
        "xlsx"
      ]
    },
    "rowCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100000
    },
    "downloadUrl": {
      "type": [
        "string",
        "null"
      ],
      "format": "uri",
      "maxLength": 4000
    },
    "expiresAtMillis": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "errorMessage": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 500
    }
  }
} as const;
