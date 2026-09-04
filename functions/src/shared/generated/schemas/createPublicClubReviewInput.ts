/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const createPublicClubReviewCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/create_public_club_review_payload.schema.json",
  "title": "CreatePublicClubReviewCallablePayload",
  "description": "Callable payload accepted by createPublicClubReview for unverified public organizer listing reviews.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "clubId",
    "rating",
    "comment",
    "reviewerName",
    "isAnonymous",
    "submittedFromPath"
  ],
  "properties": {
    "clubId": {
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
      "minLength": 1,
      "maxLength": 1000
    },
    "reviewerName": {
      "type": "string",
      "maxLength": 120
    },
    "isAnonymous": {
      "type": "boolean"
    },
    "submittedFromPath": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    }
  }
} as const;
