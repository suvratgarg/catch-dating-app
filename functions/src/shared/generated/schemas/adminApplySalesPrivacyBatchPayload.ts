/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminApplySalesPrivacyBatchPayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_apply_sales_privacy_batch_payload.schema.json",
  "title": "adminApplySalesPrivacyBatchPayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "planId",
    "requestId",
    "expectedCursor"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]{0,179}$"
    },
    "planId": {
      "type": "string",
      "pattern": "^privacy-[a-f0-9]{40}$"
    },
    "requestId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]{7,95}$"
    },
    "expectedCursor": {
      "type": "integer",
      "minimum": 0
    }
  },
  "x-callable-aliases": [
    "adminApplySalesPrivacyBatch"
  ]
} as const;
