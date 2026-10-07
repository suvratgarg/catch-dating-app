/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const registerSalesPartnerCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/register_sales_partner_payload.schema.json",
  "title": "RegisterSalesPartnerCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "requestId",
    "displayName",
    "termsVersion"
  ],
  "properties": {
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 128
    },
    "displayName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 100
    },
    "termsVersion": {
      "const": "referral-preview-v1"
    }
  },
  "x-callable-aliases": [
    "registerSalesPartner"
  ]
} as const;
