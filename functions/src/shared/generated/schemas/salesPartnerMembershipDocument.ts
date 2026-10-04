/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesPartnerMembershipDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/sales_partner_memberships.schema.json",
  "title": "SalesPartnerMembershipDocument",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "salesPartnerMemberships",
  "x-firestore-path": "salesPartnerMemberships/{id}",
  "x-document-id-field": "uid",
  "x-owner": "partner Sales scoped services",
  "required": [
    "schemaVersion",
    "classification",
    "revision",
    "createdAt",
    "updatedAt",
    "uid",
    "status",
    "termsVersion",
    "acceptedAt",
    "expiresAt",
    "displayName",
    "marketingGrants"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "classification": {
      "const": "sales_private"
    },
    "revision": {
      "type": "integer",
      "minimum": 1
    },
    "createdAt": {
      "type": "string",
      "format": "date-time"
    },
    "updatedAt": {
      "type": "string",
      "format": "date-time"
    },
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 128
    },
    "status": {
      "enum": [
        "active",
        "revoked"
      ]
    },
    "termsVersion": {
      "const": "referral-preview-v1"
    },
    "acceptedAt": {
      "type": "string",
      "format": "date-time"
    },
    "expiresAt": {
      "type": "string",
      "format": "date-time"
    },
    "displayName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 100
    },
    "marketingGrants": {
      "type": "array",
      "maxItems": 30,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "campaignId",
          "channel",
          "assetIds",
          "expiresAt"
        ],
        "properties": {
          "campaignId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 128
          },
          "channel": {
            "enum": [
              "email",
              "whatsapp",
              "other"
            ]
          },
          "assetIds": {
            "type": "array",
            "maxItems": 30,
            "uniqueItems": true,
            "items": {
              "type": "string",
              "minLength": 1,
              "maxLength": 128
            }
          },
          "expiresAt": {
            "type": "string",
            "format": "date-time"
          }
        }
      }
    }
  }
} as const;
