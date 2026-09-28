/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminReviewSalesPrivacyPolicyPayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_review_sales_privacy_policy_payload.schema.json",
  "title": "adminReviewSalesPrivacyPolicyPayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "requestId",
    "expectedRevision",
    "sourceReference",
    "sourceHash",
    "financeReason",
    "auditReason"
  ],
  "properties": {
    "requestId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]{7,95}$"
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 0
    },
    "sourceReference": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "sourceHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "financeReason": {
      "type": "string",
      "minLength": 1,
      "maxLength": 500
    },
    "auditReason": {
      "type": "string",
      "minLength": 1,
      "maxLength": 500
    }
  },
  "x-callable-aliases": [
    "adminReviewSalesPrivacyPolicy"
  ]
} as const;
