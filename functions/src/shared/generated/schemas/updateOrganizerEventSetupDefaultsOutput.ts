/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const updateOrganizerEventSetupDefaultsCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/update_organizer_event_setup_defaults_response.schema.json",
  "title": "UpdateOrganizerEventSetupDefaultsCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "appliedRevision",
    "current",
    "replayed"
  ],
  "properties": {
    "appliedRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000000000
    },
    "current": {
      "title": "OrganizerEventSetupDefaultsCallableResponse",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "organizerId",
        "city",
        "timezone",
        "organizerDefaultsRevision",
        "basicsReviewedHash",
        "preferencesRevision",
        "preferences",
        "preferencesHash",
        "reviewedDefaultsHash"
      ],
      "properties": {
        "organizerId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$"
        },
        "city": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "cityId",
                "marketId"
              ],
              "properties": {
                "cityId": {
                  "type": "string",
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$"
                },
                "marketId": {
                  "type": "string",
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$"
                }
              }
            },
            {
              "type": "null"
            }
          ]
        },
        "timezone": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 100
        },
        "organizerDefaultsRevision": {
          "type": [
            "integer",
            "null"
          ],
          "minimum": 0,
          "maximum": 1000000000
        },
        "basicsReviewedHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "preferencesRevision": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000000
        },
        "preferences": {
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
        "preferencesHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "reviewedDefaultsHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        }
      }
    },
    "replayed": {
      "type": "boolean"
    }
  }
} as const;
