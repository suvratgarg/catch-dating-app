/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesDemoPreviewCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/sales_demo_preview.schema.json",
  "title": "GetSalesDemoPreviewCallablePayload",
  "description": "Generic anonymous unfurl; personalized preview requires current invited contact and bearer grant. No session consumption.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "invitationId"
  ],
  "properties": {
    "invitationId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "grantToken": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{43}$"
    }
  },
  "x-callable": "getSalesDemoPreview"
} as const;
