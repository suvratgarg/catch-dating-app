/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const proposeSalesPartnerDemoWordingResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/propose_sales_partner_demo_wording_response.schema.json",
  "title": "ProposeSalesPartnerDemoWordingResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "blueprintId",
    "proposalRevision",
    "sourcePreviewHash",
    "state",
    "sendAuthority",
    "capabilityApprovalAuthority",
    "organizerControlAuthority"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "blueprintId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "proposalRevision": {
      "type": "integer",
      "minimum": 1
    },
    "sourcePreviewHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "state": {
      "const": "pending_owner_review"
    },
    "sendAuthority": {
      "const": false
    },
    "capabilityApprovalAuthority": {
      "const": false
    },
    "organizerControlAuthority": {
      "const": false
    }
  },
  "x-callable-aliases": [
    "proposeSalesPartnerDemoWording"
  ]
} as const;
