/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventCrossPathsConsentDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_cross_paths_consents.schema.json",
  "title": "EventCrossPathsConsentDocument",
  "description": "Private per-user Cross Paths consent edge stored at eventCrossPathsConsents/{eventId_uid} and written only by setCrossPathsEventConsent.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventCrossPathsConsents",
  "x-firestore-path": "eventCrossPathsConsents/{consentId}",
  "x-document-id-field": "id",
  "x-owner": "setCrossPathsEventConsent callable",
  "required": [
    "eventId",
    "uid",
    "enabled",
    "termsVersion",
    "consentedAt",
    "updatedAt",
    "revokedAt",
    "source"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "enabled": {
      "type": "boolean",
      "x-catch-ownership": "callable-owned"
    },
    "termsVersion": {
      "type": "integer",
      "minimum": 1,
      "x-catch-ownership": "callable-owned"
    },
    "consentedAt": {
      "anyOf": [
        {
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
        {
          "type": "null"
        }
      ],
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
    },
    "revokedAt": {
      "anyOf": [
        {
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
        {
          "type": "null"
        }
      ],
      "x-catch-ownership": "callable-owned"
    },
    "source": {
      "type": "string",
      "enum": [
        "booking_success",
        "event_detail",
        "settings"
      ],
      "x-catch-ownership": "callable-owned"
    }
  }
} as const;
