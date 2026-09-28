/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminListSalesFitQueuePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_sales_fit_queue_list_request.schema.json",
  "title": "AdminListSalesFitQueuePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "view"
  ],
  "properties": {
    "view": {
      "enum": [
        "ranked",
        "needs_research",
        "outreach_review_candidate"
      ]
    },
    "limit": {
      "type": "integer",
      "minimum": 1,
      "maximum": 25
    },
    "cursor": {
      "type": "string",
      "minLength": 1,
      "maxLength": 600
    }
  },
  "x-callable-aliases": [
    "adminListSalesFitQueue"
  ]
} as const;
