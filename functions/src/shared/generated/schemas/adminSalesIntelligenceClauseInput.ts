/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminSalesIntelligenceClauseCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_sales_intelligence_clause_payload.schema.json",
  "title": "AdminSaveSalesIntelligenceClausePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "requestId",
    "clauseId",
    "organizerId",
    "expectedRevision",
    "kind",
    "text",
    "evidenceIds",
    "validUntil",
    "permission"
  ],
  "properties": {
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "clauseId": {
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
    "expectedRevision": {
      "type": "integer",
      "minimum": 0
    },
    "kind": {
      "enum": [
        "observation",
        "capability",
        "reference",
        "cta"
      ]
    },
    "text": {
      "type": "string",
      "minLength": 1,
      "maxLength": 500
    },
    "evidenceIds": {
      "type": "array",
      "maxItems": 8,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 96,
        "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
      }
    },
    "validUntil": {
      "type": "string",
      "format": "date-time"
    },
    "permission": {
      "enum": [
        "not_required",
        "private_mention",
        "withdrawn"
      ]
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
