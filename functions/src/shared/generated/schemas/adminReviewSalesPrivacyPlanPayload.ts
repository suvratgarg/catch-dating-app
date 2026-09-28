/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminReviewSalesPrivacyPlanPayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_review_sales_privacy_plan_payload.schema.json",
  "title": "adminReviewSalesPrivacyPlanPayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "requestId",
    "restrictionRevision",
    "policyHash",
    "inventoryHash",
    "expectedActivePlanId"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]{0,179}$"
    },
    "requestId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]{7,95}$"
    },
    "restrictionRevision": {
      "type": "integer",
      "minimum": 0
    },
    "policyHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "inventoryHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "expectedActivePlanId": {
      "anyOf": [
        {
          "type": "string",
          "pattern": "^privacy-[a-f0-9]{40}$"
        },
        {
          "type": "null"
        }
      ]
    }
  },
  "x-callable-aliases": [
    "adminReviewSalesPrivacyPlan"
  ]
} as const;
