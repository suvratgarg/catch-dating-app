/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const editSalesPartnerOutreachDraftCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/edit_sales_partner_outreach_draft_payload.schema.json",
  "title": "EditSalesPartnerOutreachDraftCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "requestId",
    "organizerId",
    "expectedAssignmentRevision",
    "draftId",
    "expectedContentHash",
    "expectedCompositionRevision",
    "style"
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
    },
    "expectedCompositionRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 999999
    },
    "style": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "greeting",
        "closing",
        "subjectStyle",
        "paragraphStyle"
      ],
      "properties": {
        "greeting": {
          "enum": [
            "none",
            "hello",
            "hi"
          ]
        },
        "closing": {
          "enum": [
            "none",
            "thanks",
            "best"
          ]
        },
        "subjectStyle": {
          "enum": [
            "original",
            "question",
            "idea"
          ]
        },
        "paragraphStyle": {
          "enum": [
            "spaced",
            "compact"
          ]
        }
      }
    }
  },
  "x-callable-aliases": [
    "editSalesPartnerOutreachDraft"
  ]
} as const;
