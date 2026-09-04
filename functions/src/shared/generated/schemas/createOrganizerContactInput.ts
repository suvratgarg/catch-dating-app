/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const createOrganizerContactCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/create_organizer_contact_payload.schema.json",
  "title": "CreateOrganizerContactCallablePayload",
  "description": "Manager-only creation of an organizer CRM contact with a required name, at least one unverified phone or email endpoint, and an optional initial private note. It does not create an attendee, Consumer account, or messaging permission.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "displayName"
  ],
  "anyOf": [
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
    "displayName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "phoneE164": {
      "type": "string",
      "pattern": "^\\+[1-9][0-9]{7,14}$"
    },
    "email": {
      "type": "string",
      "format": "email",
      "maxLength": 320
    },
    "initialNote": {
      "type": "string",
      "minLength": 1,
      "maxLength": 2000
    }
  }
} as const;
