/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesIntelligenceClauseDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/sales_intelligence_clauses.schema.json",
  "title": "SalesIntelligenceClauseDocument",
  "description": "Private exact prose approved for one organizer. Revoked or expired source and reference permission block future use.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "salesIntelligenceClauses",
  "x-firestore-path": "salesIntelligenceClauses/{clauseId}",
  "x-document-id-field": "clauseId",
  "x-owner": "private Sales intelligence clause callable",
  "required": [
    "schemaVersion",
    "classification",
    "clauseId",
    "organizerId",
    "revision",
    "kind",
    "text",
    "state",
    "evidenceIds",
    "validUntil",
    "permission",
    "reviewedAt",
    "reviewedBy",
    "updatedAt",
    "updatedBy"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "classification": {
      "const": "sales_private"
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
    "revision": {
      "type": "integer",
      "minimum": 1
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
    "state": {
      "enum": [
        "draft",
        "approved",
        "withdrawn"
      ]
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
    },
    "reviewedAt": {
      "type": [
        "string",
        "null"
      ],
      "format": "date-time"
    },
    "reviewedBy": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 96,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        {
          "type": "null"
        }
      ]
    },
    "updatedAt": {
      "type": "string",
      "format": "date-time"
    },
    "updatedBy": {
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
