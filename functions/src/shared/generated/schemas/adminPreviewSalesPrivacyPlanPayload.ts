/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminPreviewSalesPrivacyPlanPayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_preview_sales_privacy_plan_payload.schema.json",
  "title": "adminPreviewSalesPrivacyPlanPayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]{0,179}$"
    }
  },
  "x-callable-aliases": [
    "adminPreviewSalesPrivacyPlan"
  ]
} as const;
