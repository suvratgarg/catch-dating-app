/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getSalesPartnerMarketingAssetsCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/get_sales_partner_marketing_assets_response.schema.json",
  "title": "GetSalesPartnerMarketingAssetsCallableResponse",
  "x-callable-aliases": [
    "getSalesPartnerMarketingAssets"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "grantId",
    "revision",
    "organizerId",
    "campaignId",
    "channel",
    "expiresAt",
    "assets",
    "sendAuthority",
    "publicationAuthority",
    "guestAuthority",
    "providerAuthority"
  ],
  "properties": {
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
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "campaignId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "channel": {
      "enum": [
        "email",
        "whatsapp",
        "other"
      ]
    },
    "expiresAt": {
      "type": "string",
      "format": "date-time",
      "maxLength": 48
    },
    "assets": {
      "type": "array",
      "minItems": 1,
      "maxItems": 12,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "assetId",
          "kind",
          "text",
          "validUntil"
        ],
        "properties": {
          "assetId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 96,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          },
          "kind": {
            "enum": [
              "capability",
              "reference",
              "cta"
            ]
          },
          "text": {
            "type": "string",
            "minLength": 1,
            "maxLength": 2000
          },
          "validUntil": {
            "type": "string",
            "format": "date-time",
            "maxLength": 48
          }
        }
      }
    },
    "sendAuthority": {
      "const": false
    },
    "publicationAuthority": {
      "const": false
    },
    "guestAuthority": {
      "const": false
    },
    "providerAuthority": {
      "const": false
    }
  }
} as const;
