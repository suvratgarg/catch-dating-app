/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listOrganizerFormsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/list_organizer_forms_payload.schema.json",
  "title": "ListOrganizerFormsCallablePayload",
  "description": "Lists bounded organizer form summaries using an opaque cursor.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "statuses",
    "purposes",
    "query",
    "cursor",
    "limit"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "statuses": {
      "type": "array",
      "maxItems": 4,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "enum": [
          "draft",
          "published",
          "paused",
          "archived"
        ]
      }
    },
    "purposes": {
      "type": "array",
      "maxItems": 6,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "enum": [
          "application",
          "registration",
          "intake",
          "waiver",
          "feedback",
          "survey"
        ]
      }
    },
    "query": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 120
    },
    "cursor": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 500
    },
    "limit": {
      "type": "integer",
      "minimum": 1,
      "maximum": 100
    }
  }
} as const;
