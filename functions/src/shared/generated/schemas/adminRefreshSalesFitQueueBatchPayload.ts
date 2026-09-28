/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminRefreshSalesFitQueueBatchPayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_sales_fit_queue_refresh_batch_request.schema.json",
  "title": "AdminRefreshSalesFitQueueBatchPayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "requestId"
  ],
  "properties": {
    "requestId": {
      "type": "string",
      "minLength": 8,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "limit": {
      "type": "integer",
      "minimum": 1,
      "maximum": 10
    },
    "cursor": {
      "type": "string",
      "minLength": 1,
      "maxLength": 600
    }
  },
  "x-callable-aliases": [
    "adminRefreshSalesFitQueueBatch"
  ]
} as const;
