/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const previewEventOffersCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/preview_event_offers_payload.schema.json",
  "title": "PreviewEventOffersCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "eventId",
    "mode",
    "rows"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9_-]{1,180}$"
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9_-]{1,180}$"
    },
    "mode": {
      "type": "string",
      "enum": [
        "draft",
        "offer"
      ]
    },
    "rows": {
      "type": "array",
      "minItems": 1,
      "maxItems": 25,
      "items": {
        "title": "EventOfferRow",
        "type": "object",
        "additionalProperties": false,
        "required": [
          "organizerId",
          "eventId",
          "contactId",
          "applicationId",
          "sourceKind",
          "expiresAtMillis",
          "organizerPaymentLink"
        ],
        "properties": {
          "organizerId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180,
            "pattern": "^[A-Za-z0-9_-]{1,180}$"
          },
          "eventId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180,
            "pattern": "^[A-Za-z0-9_-]{1,180}$"
          },
          "contactId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180,
            "pattern": "^[A-Za-z0-9_-]{1,180}$"
          },
          "applicationId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180,
            "pattern": "^[A-Za-z0-9_-]{1,180}$"
          },
          "sourceKind": {
            "type": "string",
            "enum": [
              "application",
              "formResponse"
            ]
          },
          "expiresAtMillis": {
            "type": "integer",
            "minimum": 1,
            "maximum": 9007199254740991
          },
          "organizerPaymentLink": {
            "anyOf": [
              {
                "type": "string",
                "minLength": 1,
                "maxLength": 2048,
                "format": "uri",
                "pattern": "^https://"
              },
              {
                "type": "null"
              }
            ]
          }
        }
      }
    }
  }
} as const;
