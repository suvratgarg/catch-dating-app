/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const deleteEventReviewCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/delete_event_review_payload.schema.json",
  "title": "DeleteEventReviewCallablePayload",
  "description": "Callable payload accepted by deleteEventReview.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "reviewId"
  ],
  "properties": {
    "reviewId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
