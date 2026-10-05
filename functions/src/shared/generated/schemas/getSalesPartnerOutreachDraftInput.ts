/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getSalesPartnerOutreachDraftCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/get_sales_partner_outreach_draft_payload.schema.json",
  "title": "GetSalesPartnerOutreachDraftCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "expectedAssignmentRevision",
    "draftId"
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
    },
    "draftId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    }
  },
  "x-callable-aliases": [
    "getSalesPartnerOutreachDraft"
  ]
} as const;
