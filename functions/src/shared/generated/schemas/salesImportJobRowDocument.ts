/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesImportJobRowDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/sales_import_job_rows.schema.json",
  "title": "SalesImportJobRowDocument",
  "description": "Immutable per-row review result for every row in a bounded import job.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "rows",
  "x-firestore-path": "salesImportJobs/{importId}/rows/{rowIndex}",
  "x-owner": "private Sales import service",
  "required": [
    "schemaVersion",
    "classification",
    "importId",
    "sourceId",
    "sourceRowId",
    "sourceContentHash",
    "mappingVersion",
    "organizerId",
    "disposition",
    "reason",
    "originalScore",
    "originalResearchStatus",
    "originalSummary",
    "importedAt",
    "importedBy"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "classification": {
      "const": "sales_private"
    },
    "importId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "sourceId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "sourceRowId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "sourceContentHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "mappingVersion": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "organizerId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        {
          "type": "null"
        }
      ]
    },
    "disposition": {
      "enum": [
        "created",
        "matched",
        "duplicate",
        "unresolved",
        "rejected"
      ]
    },
    "reason": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160
    },
    "originalScore": {
      "anyOf": [
        {
          "type": "object",
          "maxProperties": 12,
          "propertyNames": {
            "type": "string",
            "minLength": 1,
            "maxLength": 64,
            "pattern": "^[A-Za-z][A-Za-z0-9 _.-]*$"
          },
          "additionalProperties": {
            "anyOf": [
              {
                "type": "string",
                "minLength": 0,
                "maxLength": 500
              },
              {
                "type": "number"
              },
              {
                "type": "boolean"
              },
              {
                "type": "null"
              }
            ]
          }
        },
        {
          "type": "null"
        }
      ]
    },
    "originalCells": {
      "anyOf": [
        {
          "type": "array",
          "minItems": 0,
          "maxItems": 60,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "column",
              "value"
            ],
            "properties": {
              "column": {
                "type": "string",
                "minLength": 0,
                "maxLength": 160
              },
              "value": {
                "type": "string",
                "minLength": 0,
                "maxLength": 2000
              }
            }
          }
        },
        {
          "type": "null"
        }
      ]
    },
    "originalResearchStatus": {
      "enum": [
        "new",
        "needs_research",
        "ready_for_review",
        "qualified",
        "benchmark_only",
        "no_fit",
        "archived"
      ]
    },
    "originalSummary": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 0,
          "maxLength": 1200
        },
        {
          "type": "null"
        }
      ]
    },
    "importedAt": {
      "type": "string",
      "format": "date-time",
      "maxLength": 48
    },
    "importedBy": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "cohortIds": {
      "type": "array",
      "maxItems": 30,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 96,
        "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
      }
    }
  }
} as const;
