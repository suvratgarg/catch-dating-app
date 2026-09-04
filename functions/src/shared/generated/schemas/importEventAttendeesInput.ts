/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const importEventAttendeesCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/import_event_attendees_payload.schema.json",
  "title": "ImportEventAttendeesCallablePayload",
  "description": "Callable payload accepted by importEventAttendees.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "importKey",
    "fileName",
    "format",
    "rows"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "importKey": {
      "type": "string",
      "minLength": 8,
      "maxLength": 120
    },
    "fileName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 255
    },
    "format": {
      "type": "string",
      "enum": [
        "csv",
        "xlsx",
        "manual"
      ]
    },
    "rows": {
      "type": "array",
      "minItems": 1,
      "maxItems": 250,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "rowId",
          "displayName",
          "status"
        ],
        "properties": {
          "rowId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
          },
          "displayName": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
          },
          "phone": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 40
          },
          "email": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 320
          },
          "externalReference": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 180
          },
          "arrivalGroup": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 180
          },
          "ticketType": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 120
          },
          "revenueAmountMinor": {
            "type": [
              "integer",
              "null"
            ],
            "minimum": 0,
            "maximum": 9007199254740991
          },
          "revenueCurrency": {
            "type": [
              "string",
              "null"
            ],
            "pattern": "^[A-Z]{3}$"
          },
          "revenueSource": {
            "type": [
              "string",
              "null"
            ],
            "enum": [
              "hostImport",
              "hostEstimate",
              null
            ]
          },
          "status": {
            "type": "string",
            "enum": [
              "invited",
              "registered",
              "waitlisted"
            ]
          }
        }
      }
    }
  }
} as const;
