/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminListSalesCommercialReportCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_list_sales_commercial_report_payload.schema.json",
  "title": "commercial.report request",
  "description": "Strict bounded private Sales commercial read.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "limit": {
      "type": "integer",
      "minimum": 1,
      "maximum": 25
    },
    "cursor": {
      "type": "string",
      "minLength": 1,
      "maxLength": 512
    }
  }
} as const;
