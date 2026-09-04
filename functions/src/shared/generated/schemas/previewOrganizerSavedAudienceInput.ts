/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const previewOrganizerSavedAudienceCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/preview_organizer_saved_audience_payload.schema.json",
  "title": "PreviewOrganizerSavedAudienceCallablePayload",
  "description": "Resolves an exact bounded preview for one saved CRM audience.",
  "x-callable-aliases": [
    "previewOrganizerSavedAudience"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "audienceId"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "audienceId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expectedRevision": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "sampleLimit": {
      "type": "integer",
      "minimum": 0,
      "maximum": 25,
      "default": 10
    },
    "cursor": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 2048
    }
  }
} as const;
