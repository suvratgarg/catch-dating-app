/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventOfferListCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/event_offer_list_response.schema.json",
  "title": "EventOfferListCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "items",
    "nextCursor"
  ],
  "properties": {
    "items": {
      "type": "array",
      "maxItems": 50,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "offerId",
          "eventId",
          "contactId",
          "sourceKind",
          "sourceId",
          "status",
          "effectiveStatus",
          "paymentStatus",
          "revision",
          "generation",
          "expiresAtMillis"
        ],
        "properties": {
          "offerId": {
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
          "sourceKind": {
            "type": "string",
            "enum": [
              "application",
              "formResponse"
            ]
          },
          "sourceId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180,
            "pattern": "^[A-Za-z0-9_-]{1,180}$"
          },
          "status": {
            "type": "string",
            "enum": [
              "draft",
              "offered",
              "withdrawn",
              "expired"
            ]
          },
          "effectiveStatus": {
            "type": "string",
            "enum": [
              "draft",
              "offered",
              "withdrawn",
              "expired"
            ]
          },
          "paymentStatus": {
            "type": "string",
            "enum": [
              "none",
              "evidenceSubmitted",
              "hostAttestedReceived",
              "rejected"
            ]
          },
          "revision": {
            "type": "integer",
            "minimum": 1,
            "maximum": 9007199254740991
          },
          "generation": {
            "type": "integer",
            "minimum": 1,
            "maximum": 9007199254740991
          },
          "expiresAtMillis": {
            "type": "integer",
            "minimum": 1,
            "maximum": 9007199254740991
          }
        }
      }
    },
    "nextCursor": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "pattern": "^[A-Za-z0-9_-]{1,180}$"
        },
        {
          "type": "null"
        }
      ]
    }
  }
} as const;
