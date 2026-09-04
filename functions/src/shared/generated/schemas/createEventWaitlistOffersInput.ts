/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const createEventWaitlistOffersCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/create_event_waitlist_offers_payload.schema.json",
  "title": "CreateEventWaitlistOffersCallablePayload",
  "description": "Callable payload accepted by createEventWaitlistOffers.",
  "x-callable-aliases": [
    "createEventWaitlistOffers"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "userIds"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "userIds": {
      "type": "array",
      "minItems": 1,
      "maxItems": 25,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      }
    },
    "expiresInMinutes": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 5,
      "maximum": 1440
    }
  }
} as const;
