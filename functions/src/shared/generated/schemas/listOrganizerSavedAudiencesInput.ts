/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listOrganizerSavedAudiencesCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/list_organizer_saved_audiences_payload.schema.json",
  "title": "ListOrganizerSavedAudiencesCallablePayload",
  "description": "Lists one organizer's reusable CRM audiences.",
  "x-callable-aliases": [
    "listOrganizerSavedAudiences"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "status": {
      "type": "string",
      "enum": [
        "active",
        "archived"
      ],
      "default": "active"
    },
    "limit": {
      "type": "integer",
      "minimum": 1,
      "maximum": 50
    },
    "cursor": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 1000
    },
    "includeFilterOptions": {
      "type": "boolean"
    }
  }
} as const;
