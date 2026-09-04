/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const publishOrganizerApplicationFormCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/publish_organizer_application_form_response.schema.json",
  "title": "PublishOrganizerApplicationFormCallableResponse",
  "description": "Published organizer application form identity and revision.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "formId",
    "formVersionId",
    "version",
    "revision"
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
    "version": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000000
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    }
  }
} as const;
