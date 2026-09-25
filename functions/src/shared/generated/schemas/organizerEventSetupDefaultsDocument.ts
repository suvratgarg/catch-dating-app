/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerEventSetupDefaultsDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_event_setup_defaults.schema.json",
  "title": "OrganizerEventSetupDefaultsDocument",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "revision",
    "eventSetup",
    "updatedAt",
    "updatedByUid"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$"
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000000000
    },
    "eventSetup": {
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
        },
        "timezone": {
          "type": "string",
          "minLength": 1,
          "maxLength": 100
        }
      }
    },
    "updatedAt": {
      "type": "object",
      "description": "Serialized Firestore Timestamp fixture shape.",
      "x-firestore-type": "timestamp",
      "additionalProperties": false,
      "required": [
        "_seconds",
        "_nanoseconds"
      ],
      "properties": {
        "_seconds": {
          "type": "integer"
        },
        "_nanoseconds": {
          "type": "integer",
          "minimum": 0,
          "maximum": 999999999
        }
      }
    },
    "updatedByUid": {
      "type": "string",
      "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$"
    }
  },
  "x-firestore-collection": "organizerEventSetupDefaults",
  "x-firestore-path": "organizerEventSetupDefaults/{organizerId}",
  "x-document-id-field": "organizerId",
  "x-owner": "organizer event setup manager operations"
} as const;
