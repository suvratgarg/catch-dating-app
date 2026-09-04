/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminListOrganizerDetailsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_list_organizer_details_payload.schema.json",
  "title": "AdminListOrganizerDetailsCallablePayload",
  "description": "Callable payload accepted by adminListOrganizerDetails. This lists canonical organizer profile rows from organizers/{organizerId} for the admin publishing workspace.",
  "type": "object",
  "additionalProperties": false,
  "properties": {
    "query": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 160
    },
    "citySlug": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 120,
          "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
        },
        {
          "type": "null"
        }
      ]
    },
    "citySlugs": {
      "anyOf": [
        {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120,
            "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
          },
          "minItems": 1,
          "maxItems": 10,
          "uniqueItems": true
        },
        {
          "type": "null"
        }
      ]
    },
    "publishStatus": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        "draft",
        "qa",
        "published",
        "suppressed",
        "removed",
        null
      ]
    },
    "appVisibility": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        "discoverable",
        "hidden",
        null
      ]
    },
    "limit": {
      "type": "integer",
      "minimum": 1,
      "maximum": 100
    }
  }
} as const;
