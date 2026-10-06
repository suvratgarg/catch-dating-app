/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getSalesPartnerMarketingAssetsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/get_sales_partner_marketing_assets_payload.schema.json",
  "title": "GetSalesPartnerMarketingAssetsCallablePayload",
  "x-callable-aliases": [
    "getSalesPartnerMarketingAssets"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "grantId",
    "expectedGrantRevision"
  ],
  "properties": {
    "grantId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "expectedGrantRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000000
    }
  }
} as const;
