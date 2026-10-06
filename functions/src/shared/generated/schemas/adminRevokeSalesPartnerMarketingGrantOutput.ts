/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminRevokeSalesPartnerMarketingGrantCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/admin_revoke_sales_partner_marketing_grant_response.schema.json",
  "title": "AdminRevokeSalesPartnerMarketingGrantCallableResponse",
  "x-callable-aliases": [
    "adminRevokeSalesPartnerMarketingGrant"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "partnerUid",
    "grantId",
    "revision",
    "membershipRevision",
    "status"
  ],
  "properties": {
    "partnerUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "grantId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000000
    },
    "membershipRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000000
    },
    "status": {
      "const": "revoked"
    }
  }
} as const;
