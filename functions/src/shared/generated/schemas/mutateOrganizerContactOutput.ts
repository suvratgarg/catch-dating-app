/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const mutateOrganizerContactCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/mutate_organizer_contact_response.schema.json",
  "title": "MutateOrganizerContactCallableResponse",
  "description": "Safe state returned after an organizer-scoped contact mutation.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "contactId",
    "displayName",
    "displayNameOverride",
    "whatsappAdminSuppressed",
    "hidden",
    "revision"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "contactId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "displayName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "displayNameOverride": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 120
    },
    "whatsappAdminSuppressed": {
      "type": "boolean"
    },
    "hidden": {
      "type": "boolean"
    },
    "manualTags": {
      "type": "array",
      "maxItems": 5,
      "uniqueItems": true,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "tagId",
          "label"
        ],
        "properties": {
          "tagId": {
            "type": "string",
            "pattern": "^[a-f0-9]{32}$"
          },
          "label": {
            "type": "string",
            "minLength": 1,
            "maxLength": 40
          }
        }
      }
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    }
  }
} as const;
