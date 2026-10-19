/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const manageWebsiteAccountCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/manage_website_account_payload.schema.json",
  "title": "ManageWebsiteAccountCallablePayload",
  "description": "Read or complete the authenticated account with minimal identity. Phone ownership comes from Firebase Auth, never payload data.",
  "oneOf": [
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "action"
      ],
      "properties": {
        "action": {
          "const": "read"
        },
        "organizerId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "eventId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "action",
        "displayName",
        "expectedProfileRevision",
        "expectedUid"
      ],
      "properties": {
        "action": {
          "const": "complete"
        },
        "displayName": {
          "type": "string",
          "minLength": 1,
          "maxLength": 80,
          "pattern": ".*\\S.*"
        },
        "dateOfBirth": {
          "type": "string",
          "format": "date",
          "description": "Optional real birth date. Omission preserves existing data; no placeholder is synthesized."
        },
        "expectedProfileRevision": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "organizerId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "eventId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "expectedUid": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        }
      }
    }
  ]
} as const;
