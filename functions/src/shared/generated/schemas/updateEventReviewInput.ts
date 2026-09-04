/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const updateEventReviewCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/update_event_review_payload.schema.json",
  "title": "UpdateEventReviewCallablePayload",
  "description": "Callable payload accepted by updateEventReview.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "reviewId",
    "rating",
    "comment"
  ],
  "properties": {
    "reviewId": {
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
