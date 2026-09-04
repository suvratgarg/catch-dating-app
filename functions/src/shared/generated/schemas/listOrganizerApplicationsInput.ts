/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listOrganizerApplicationsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/list_organizer_applications_payload.schema.json",
  "title": "ListOrganizerApplicationsCallablePayload",
  "description": "Manager-authorized paginated organizer application review query.",
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
    "contactId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180,
      "description": "Restrict to this organizer customer through an explicit contact link or verified account identity. Never matches raw phone or email."
    },
    "formId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "targetId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "reviewStatus": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        null,
        "submitted",
        "inReview",
        "approved",
        "waitlisted",
        "declined",
        "withdrawn"
      ]
    },
    "query": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 160
    },
    "sort": {
      "type": "string",
      "enum": [
        "newest",
        "oldest",
        "name"
      ],
      "default": "newest"
    },
    "limit": {
      "type": "integer",
      "minimum": 1,
      "maximum": 100
    },
    "cursor": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 1000
    }
  }
} as const;
