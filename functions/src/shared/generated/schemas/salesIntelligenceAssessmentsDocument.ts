/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesIntelligenceAssessmentsDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/sales_intelligence_assessments.schema.json",
  "title": "SalesIntelligenceAssessmentDocument",
  "description": "Employee-reviewed factor rating linked to existing reviewed Sales evidence; unknown and disputed ratings cannot score.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "salesIntelligenceAssessments",
  "x-firestore-path": "salesIntelligenceAssessments/{assessmentId}",
  "x-document-id-field": "assessmentId",
  "x-owner": "private Sales intelligence assessment callable",
  "required": [
    "schemaVersion",
    "classification",
    "assessmentId",
    "organizerId",
    "factorId",
    "revision",
    "state",
    "value",
    "evidenceIds",
    "reason",
    "reviewedAt",
    "reviewerUid"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "classification": {
      "const": "sales_private"
    },
    "assessmentId": {
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
    "revision": {
      "type": "integer",
      "minimum": 1
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
    },
    "reviewedAt": {
      "type": "string",
      "format": "date-time"
    },
    "reviewerUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
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
