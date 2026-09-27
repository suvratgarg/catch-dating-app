/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesImportJobDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/sales_import_jobs.schema.json",
  "title": "SalesImportJobDocument",
  "description": "Reviewed 25-row maximum import receipt; row details live in a private subcollection.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "salesImportJobs",
  "x-firestore-path": "salesImportJobs/{importId}",
  "x-owner": "private Sales import service",
  "required": [
    "schemaVersion",
    "classification",
    "importId",
    "sourceId",
    "contentHash",
    "mappingVersion",
    "previewHash",
    "rowCount",
    "counts",
    "status",
    "createdAt",
    "createdBy"
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
    "contentHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "mappingVersion": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "previewHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "rowCount": {
      "type": "integer",
      "minimum": 1,
      "maximum": 25
    },
    "counts": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "created",
        "matched",
        "duplicate",
        "unresolved",
        "rejected"
      ],
      "properties": {
        "created": {
          "type": "integer",
          "minimum": 0,
          "maximum": 25
        },
        "matched": {
          "type": "integer",
          "minimum": 0,
          "maximum": 25
        },
        "duplicate": {
          "type": "integer",
          "minimum": 0,
          "maximum": 25
        },
        "unresolved": {
          "type": "integer",
          "minimum": 0,
          "maximum": 25
        },
        "rejected": {
          "type": "integer",
          "minimum": 0,
          "maximum": 25
        }
      }
    },
    "status": {
      "const": "applied"
    },
    "createdAt": {
      "type": "string",
      "format": "date-time",
      "maxLength": 48
    },
    "createdBy": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  },
  "x-document-id-field": "importId"
} as const;
