/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getSalesPartnerPreparationCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/get_sales_partner_preparation_payload.schema.json",
  "title": "GetSalesPartnerPreparationCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "expectedAssignmentRevision"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "expectedAssignmentRevision": {
      "type": "integer",
      "minimum": 1
    }
  },
  "x-callable-aliases": [
    "getSalesPartnerPreparation"
  ]
} as const;
