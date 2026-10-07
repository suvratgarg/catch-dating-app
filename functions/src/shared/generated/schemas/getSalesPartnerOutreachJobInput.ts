/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getSalesPartnerOutreachJobCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/get_sales_partner_outreach_job_payload.schema.json",
  "title": "GetSalesPartnerOutreachJobCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "requestId",
    "organizerId",
    "expectedAssignmentRevision"
  ],
  "properties": {
    "requestId": {
      "type": "string",
      "minLength": 8,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
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
    "getSalesPartnerOutreachJob"
  ]
} as const;
