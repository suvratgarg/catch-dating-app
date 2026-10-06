/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getSalesPartnerDemoReviewsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/get_sales_partner_demo_reviews_payload.schema.json",
  "title": "GetSalesPartnerDemoReviewsCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "expectedAssignmentRevision"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "expectedAssignmentRevision": {
      "type": "integer",
      "minimum": 1
    }
  },
  "x-callable-aliases": [
    "getSalesPartnerDemoReviews"
  ]
} as const;
