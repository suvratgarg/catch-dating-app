/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const prepareSalesDemoContinuationFormCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/prepare_sales_demo_continuation_form_payload.schema.json",
  "title": "PrepareSalesDemoContinuationFormCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "continuationId",
    "setupHash"
  ],
  "properties": {
    "continuationId": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "setupHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    }
  },
  "x-callable-aliases": [
    "prepareSalesDemoContinuationForm"
  ]
} as const;
