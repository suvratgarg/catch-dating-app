/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const reviewSalesPartnerOutreachDraftResponseSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "draftId",
    "exactContentHash",
    "compositionReviewed",
    "capabilityApprovalAuthority",
    "sendAuthority",
    "providerConfirmed"
  ],
  "properties": {
    "draftId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "exactContentHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "compositionReviewed": {
      "const": true
    },
    "capabilityApprovalAuthority": {
      "const": false
    },
    "sendAuthority": {
      "const": false
    },
    "providerConfirmed": {
      "const": false
    }
  },
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/review_sales_partner_outreach_draft_response.schema.json",
  "title": "ReviewSalesPartnerOutreachDraftResponse",
  "x-callable-aliases": [
    "reviewSalesPartnerOutreachDraft"
  ]
} as const;
