/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminSalesIntelligenceAssessmentCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_sales_intelligence_assessment_payload.schema.json",
  "title": "AdminSaveSalesFactorAssessmentPayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "requestId",
    "organizerId",
    "factorId",
    "expectedRevision",
    "state",
    "value",
    "evidenceIds",
    "reason"
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
    "factorId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 0
    },
    "state": {
      "enum": [
        "known",
        "unknown",
        "disputed"
      ]
    },
    "value": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 0,
      "maximum": 5
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
    "reason": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 240
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
