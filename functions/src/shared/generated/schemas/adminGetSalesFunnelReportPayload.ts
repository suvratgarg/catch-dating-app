/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminGetSalesFunnelReportPayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "additionalProperties": false,
  "title": "AdminGetSalesFunnelReportPayload",
  "x-callable-aliases": [
    "adminGetSalesFunnelReport"
  ],
  "required": [
    "since"
  ],
  "properties": {
    "since": {
      "type": "string",
      "format": "date-time"
    }
  },
  "$id": "https://catch.app/contracts/callables/admin_sales_funnel_report.schema.json"
} as const;
