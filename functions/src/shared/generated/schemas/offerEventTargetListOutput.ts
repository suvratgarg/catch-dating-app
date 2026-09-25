/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const offerEventTargetListCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/offer_event_target_list_response.schema.json",
  "title": "OfferEventTargetListCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "events",
    "nextCursor"
  ],
  "properties": {
    "events": {
      "type": "array",
      "maxItems": 50,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "eventId",
          "name",
          "startTimeMillis",
          "timezone",
          "publicationState",
          "setupRevision"
        ],
        "properties": {
          "eventId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "name": {
            "type": [
              "string",
              "null"
            ],
            "minLength": 1,
            "maxLength": 120
          },
          "startTimeMillis": {
            "type": "integer",
            "minimum": 0
          },
          "timezone": {
            "type": [
              "string",
              "null"
            ],
            "minLength": 1,
            "maxLength": 100
          },
          "publicationState": {
            "type": "string",
            "enum": [
              "private",
              "published"
            ]
          },
          "setupRevision": {
            "type": [
              "integer",
              "null"
            ],
            "minimum": 1
          }
        }
      }
    },
    "nextCursor": {
      "anyOf": [
        {
          "type": "null"
        },
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 1024,
          "pattern": "^[A-Za-z0-9_-]+$"
        }
      ]
    }
  }
} as const;
