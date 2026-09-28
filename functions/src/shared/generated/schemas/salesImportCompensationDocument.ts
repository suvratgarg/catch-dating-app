/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesImportCompensationDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/sales_import_compensations.schema.json",
  "title": "SalesImportCompensationDocument",
  "description": "Immutable private per-import per-organizer compensating effect; original job and lineage remain intact.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "salesImportCompensations",
  "x-firestore-path": "salesImportCompensations/{effectId}",
  "x-owner": "private Sales import compensation service",
  "required": [
    "schemaVersion",
    "classification",
    "effectId",
    "importId",
    "organizerId",
    "mode",
    "sourceRowIds",
    "cohortIdsRemoved",
    "beforeRevision",
    "afterRevision",
    "beforeCohortMutationId",
    "afterCohortMutationId",
    "reason",
    "createdAt",
    "createdBy",
    "requestId"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "classification": {
      "const": "sales_private"
    },
    "effectId": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "importId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "mode": {
      "enum": [
        "archive_companion",
        "remove_cohorts"
      ]
    },
    "sourceRowIds": {
      "type": "array",
      "minItems": 1,
      "maxItems": 25,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180,
        "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
      }
    },
    "cohortIdsRemoved": {
      "type": "array",
      "maxItems": 30,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180,
        "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
      }
    },
    "beforeRevision": {
      "type": "integer",
      "minimum": 1
    },
    "afterRevision": {
      "type": "integer",
      "minimum": 2
    },
    "beforeCohortMutationId": {
      "anyOf": [
        {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        {
          "const": "initial"
        }
      ]
    },
    "afterCohortMutationId": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "reason": {
      "type": "string",
      "minLength": 1,
      "maxLength": 2000
    },
    "createdAt": {
      "type": "string",
      "format": "date-time"
    },
    "createdBy": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    }
  },
  "x-document-id-field": "effectId"
} as const;
