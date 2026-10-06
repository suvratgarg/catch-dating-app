/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const editSalesPartnerOutreachDraftResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/edit_sales_partner_outreach_draft_response.schema.json",
  "title": "EditSalesPartnerOutreachDraftResponse",
  "x-callable-aliases": [
    "editSalesPartnerOutreachDraft"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "draftId",
    "contentHash",
    "compositionRevision",
    "status",
    "sendAuthority"
  ],
  "properties": {
    "draftId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "contentHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "compositionRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000000
    },
    "status": {
      "const": "pending_review"
    },
    "sendAuthority": {
      "const": false
    }
  }
} as const;
