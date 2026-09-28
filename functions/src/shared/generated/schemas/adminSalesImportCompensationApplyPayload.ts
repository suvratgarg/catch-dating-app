/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminSalesImportCompensationApplyPayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_sales_import_compensation_apply_payload.schema.json",
  "title": "AdminSalesImportCompensationApplyPayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "importId",
    "organizerId",
    "requestId",
    "previewHash",
    "reason"
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
    },
    "requestId": {
      "type": "string",
      "minLength": 8,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "previewHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "reason": {
      "type": "string",
      "minLength": 1,
      "maxLength": 2000
    }
  },
  "x-callable-aliases": [
    "adminApplySalesImportCompensation"
  ]
} as const;
