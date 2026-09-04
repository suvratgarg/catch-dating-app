/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const mutateOrganizerContactCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/mutate_organizer_contact_payload.schema.json",
  "title": "MutateOrganizerContactCallablePayload",
  "description": "Manager-only organizer-scoped contact correction, manual identity detail update, suppression, or hiding request.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "contactId",
    "expectedRevision"
  ],
  "anyOf": [
    {
      "required": [
        "displayNameOverride"
      ]
    },
    {
      "required": [
        "whatsappAdminSuppressed"
      ]
    },
    {
      "required": [
        "hidden"
      ]
    },
    {
      "required": [
        "manualTags"
      ]
    },
    {
      "required": [
        "phoneE164"
      ]
    },
    {
      "required": [
        "email"
      ]
    }
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
    "expectedRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "displayNameOverride": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 120
    },
    "phoneE164": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^\\+[1-9][0-9]{7,14}$"
    },
    "email": {
      "type": [
        "string",
        "null"
      ],
      "format": "email",
      "maxLength": 320
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
        "type": "string",
        "minLength": 1,
        "maxLength": 40
      }
    }
  }
} as const;
