/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const createEventReviewCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/create_event_review_payload.schema.json",
  "title": "CreateEventReviewCallablePayload",
  "description": "Callable payload accepted by createEventReview.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "eventId",
    "rating",
    "comment"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "rating": {
      "type": "integer",
      "minimum": 1,
      "maximum": 5
    },
    "comment": {
      "type": "string",
      "maxLength": 1000
    }
  }
} as const;
