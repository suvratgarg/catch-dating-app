/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminCopySalesOutreachDraftRequestSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_sales_outreach_copy_request.schema.json",
  "title": "AdminCopySalesOutreachDraftRequest",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "requestId",
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
    "draftId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "expectedContentHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    }
  },
  "definitions": {
    "id": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "requestId": {
      "type": "string",
      "minLength": 8,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "hash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    }
  }
} as const;
