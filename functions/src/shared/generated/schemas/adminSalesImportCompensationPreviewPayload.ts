/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminSalesImportCompensationPreviewPayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_sales_import_compensation_preview_payload.schema.json",
  "title": "AdminSalesImportCompensationPreviewPayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "importId",
    "organizerId"
  ],
  "properties": {
    "importId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    }
  },
  "x-callable-aliases": [
    "adminPreviewSalesImportCompensation"
  ]
} as const;
