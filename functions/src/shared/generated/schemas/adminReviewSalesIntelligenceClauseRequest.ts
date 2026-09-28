/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminReviewSalesIntelligenceClauseRequestSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_sales_intelligence_clause_review_request.schema.json",
  "title": "AdminReviewSalesIntelligenceClauseRequest",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "requestId",
    "clauseId",
    "expectedRevision",
    "decision"
  ],
  "properties": {
    "requestId": {
      "type": "string",
      "minLength": 8,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "clauseId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 0
    },
    "decision": {
      "enum": [
        "approve",
        "withdraw"
      ]
    }
  },
  "definitions": {
    "id": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "requestId": {
      "type": "string",
      "minLength": 8,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    }
  }
} as const;
