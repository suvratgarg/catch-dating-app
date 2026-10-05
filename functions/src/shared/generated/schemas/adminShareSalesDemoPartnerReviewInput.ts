/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminShareSalesDemoPartnerReviewCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_share_sales_demo_partner_review_payload.schema.json",
  "title": "AdminShareSalesDemoPartnerReviewCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "requestId",
    "blueprintId",
    "expectedBlueprintRevision",
    "expectedSharingRevision",
    "partnerUid",
    "expectedAssignmentRevision",
    "expectedPreviewHash",
    "decision",
    "expiresAt"
  ],
  "properties": {
    "requestId": {
      "type": "string",
      "minLength": 8,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "blueprintId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "expectedBlueprintRevision": {
      "type": "integer",
      "minimum": 1
    },
    "expectedSharingRevision": {
      "type": "integer",
      "minimum": 0
    },
    "partnerUid": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "expectedAssignmentRevision": {
      "type": "integer",
      "minimum": 1
    },
    "expectedPreviewHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "decision": {
      "type": "string",
      "enum": [
        "share",
        "withdraw"
      ]
    },
    "expiresAt": {
      "anyOf": [
        {
          "type": "string",
          "format": "date-time"
        },
        {
          "type": "null"
        }
      ]
    }
  },
  "x-callable-aliases": [
    "adminShareSalesDemoPartnerReview"
  ]
} as const;
