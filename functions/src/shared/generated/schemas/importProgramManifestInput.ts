/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const importProgramManifestCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/import_program_manifest_payload.schema.json",
  "title": "ImportProgramManifestCallablePayload",
  "description": "Bulk manifest import for a program. Preview mode plans without writing; commit mode applies idempotently via clientOperationId. Rows describe one guest and, optionally, that guest's inbound travel leg.",
  "type": "object",
  "additionalProperties": false,
  "x-callable-aliases": [
    "importProgramManifest"
  ],
  "required": [
    "programId",
    "mode",
    "clientOperationId",
    "rows"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "mode": {
      "type": "string",
      "enum": [
        "preview",
        "commit"
      ]
    },
    "clientOperationId": {
      "type": "string",
      "minLength": 8,
      "maxLength": 120
    },
    "rows": {
      "type": "array",
      "minItems": 1,
      "maxItems": 500,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "displayName"
        ],
        "properties": {
          "externalReference": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 180,
            "description": "Stable upstream id (CRM row id). Primary dedup key; without it, dedup falls back to displayName + flightNumber + arrival day."
          },
          "displayName": {
            "type": "string",
            "minLength": 1,
            "maxLength": 140
          },
          "phoneE164": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 20
          },
          "email": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 320
          },
          "householdLabel": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 140,
            "description": "Matched against program households by case-insensitive label; unmatched labels create a household."
          },
          "partyLabel": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 140,
            "description": "Ride-together travel party label; matched or created per program."
          },
          "flightNumber": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 10
          },
          "originIata": {
            "anyOf": [
              {
                "type": "string",
                "pattern": "^[A-Z]{3}$"
              },
              {
                "type": "null"
              }
            ]
          },
          "destinationIata": {
            "anyOf": [
              {
                "type": "string",
                "pattern": "^[A-Z]{3}$"
              },
              {
                "type": "null"
              }
            ]
          },
          "scheduledArrivalAtMillis": {
            "type": [
              "integer",
              "null"
            ],
            "minimum": 1,
            "maximum": 9007199254740991
          },
          "international": {
            "type": [
              "boolean",
              "null"
            ]
          },
          "pickupPointLabel": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 140,
            "description": "Must match an existing program pickup point label; unmatched values are row errors."
          },
          "destinationHotelName": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 140,
            "description": "Must match an existing program hotel name; unmatched values are row errors."
          },
          "destinationLabel": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 140,
            "description": "Free-text destination fallback when no program hotel applies."
          },
          "passengers": {
            "type": [
              "integer",
              "null"
            ],
            "minimum": 1,
            "maximum": 20
          },
          "luggageUnits": {
            "type": [
              "integer",
              "null"
            ],
            "minimum": 0,
            "maximum": 40
          }
        }
      }
    }
  }
} as const;
