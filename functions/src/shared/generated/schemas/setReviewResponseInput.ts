/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const setReviewResponseCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/set_review_response_payload.schema.json",
  "title": "SetReviewResponseCallablePayload",
  "description": "Callable payload accepted by setReviewResponse.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "reviewId",
    "message"
  ],
  "properties": {
    "reviewId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "message": {
      "type": "string",
      "minLength": 1,
      "maxLength": 1000
    }
  }
} as const;
