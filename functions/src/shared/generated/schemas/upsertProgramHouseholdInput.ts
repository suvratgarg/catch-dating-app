/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const upsertProgramHouseholdCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/upsert_program_household_payload.schema.json",
  "title": "UpsertProgramHouseholdCallablePayload",
  "description": "Create or update a household/party grouping for program guests.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "programId",
    "label",
    "primaryContactName",
    "memberGuestIds"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "householdId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "label": {
      "type": "string",
      "minLength": 1,
      "maxLength": 140
    },
    "primaryContactName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 140
    },
    "primaryPhoneE164": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 20
    },
    "primaryEmail": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 320
    },
    "memberGuestIds": {
      "type": "array",
      "minItems": 1,
      "maxItems": 50,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      }
    },
    "deliveryPreference": {
      "type": "string",
      "enum": [
        "whatsapp",
        "sms",
        "email",
        "none"
      ]
    }
  }
} as const;
