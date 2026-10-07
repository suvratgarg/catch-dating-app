/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const copySalesPartnerOutreachDraftCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/copy_sales_partner_outreach_draft_payload.schema.json",
  "title": "CopySalesPartnerOutreachDraftCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "requestId",
    "organizerId",
    "expectedAssignmentRevision",
    "draftId",
    "expectedContentHash"
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
    },
    "draftId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "expectedContentHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    }
  },
  "x-callable-aliases": [
    "copySalesPartnerOutreachDraft"
  ]
} as const;
