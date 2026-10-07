/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getSalesPartnerWorkspaceCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/get_sales_partner_workspace_payload.schema.json",
  "title": "GetSalesPartnerWorkspaceCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [],
  "properties": {
    "cursor": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 128
    }
  },
  "x-callable-aliases": [
    "getSalesPartnerWorkspace"
  ]
} as const;
