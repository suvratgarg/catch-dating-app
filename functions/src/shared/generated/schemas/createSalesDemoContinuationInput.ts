/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const createSalesDemoContinuationCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/create_sales_demo_continuation_payload.schema.json",
  "title": "CreateSalesDemoContinuationCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "sessionId",
    "grantToken"
  ],
  "properties": {
    "sessionId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "grantToken": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{43}$"
    }
  },
  "x-callable-aliases": [
    "createSalesDemoContinuation"
  ]
} as const;
