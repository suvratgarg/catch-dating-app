/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const exportOrganizerContactsCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/export_organizer_contacts_response.schema.json",
  "title": "ExportOrganizerContactsCallableResponse",
  "description": "Bounded UTF-8 CRM CSV that omits private Event Success, dating, feedback, and safety answers.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "fileName",
    "csv",
    "rowCount",
    "truncated",
    "generatedAtMillis",
    "sourceCoverage"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "fileName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "csv": {
      "type": "string",
      "minLength": 1,
      "maxLength": 5000000
    },
    "rowCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 2500
    },
    "truncated": {
      "type": "boolean"
    },
    "generatedAtMillis": {
      "type": "integer",
      "minimum": 0
    },
    "sourceCoverage": {
      "type": "string",
      "enum": [
        "exact",
        "partial"
      ]
    }
  }
} as const;
