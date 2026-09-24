/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerEventSetupPreferencesSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/embedded/organizer_event_setup_preferences.schema.json",
  "title": "OrganizerEventSetupPreferences",
  "type": "object",
  "additionalProperties": false,
  "required": [],
  "properties": {
    "usualDurationMinutes": {
      "type": "integer",
      "minimum": 15,
      "maximum": 240
    },
    "preferredVenueId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$"
    },
    "offerValidityMinutes": {
      "type": "integer",
      "minimum": 5,
      "maximum": 10080
    },
    "collectionPreference": {
      "type": "string",
      "enum": [
        "manualInstructions",
        "reusablePage",
        "personalRequest",
        "catchCheckout"
      ]
    },
    "currency": {
      "type": "string",
      "pattern": "^[A-Z]{3}$"
    },
    "offerMessageTemplate": {
      "type": "string",
      "minLength": 1,
      "maxLength": 1000
    },
    "paymentInstructions": {
      "type": "string",
      "minLength": 1,
      "maxLength": 1000
    },
    "reusablePaymentPage": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "url",
        "reusableForEvents"
      ],
      "properties": {
        "url": {
          "type": "string",
          "format": "uri",
          "maxLength": 2048
        },
        "reusableForEvents": {
          "type": "boolean",
          "const": true
        }
      }
    }
  }
} as const;
