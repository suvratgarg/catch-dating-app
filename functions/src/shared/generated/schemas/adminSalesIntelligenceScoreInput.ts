/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminSalesIntelligenceScoreCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_sales_intelligence_score_payload.schema.json",
  "title": "AdminSaveSalesScoreSnapshotPayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "requestId",
    "organizerId",
    "expectedAccountRevision",
    "expectedPolicyRevision"
  ],
  "properties": {
    "requestId": {
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
    "expectedAccountRevision": {
      "type": "integer",
      "minimum": 0
    },
    "expectedPolicyRevision": {
      "type": "integer",
      "minimum": 0
    }
  },
  "definitions": {
    "id": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    }
  }
} as const;
