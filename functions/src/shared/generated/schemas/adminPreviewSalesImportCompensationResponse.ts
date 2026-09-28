/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminPreviewSalesImportCompensationResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/admin_sales_import_compensation_preview_response.schema.json",
  "title": "AdminPreviewSalesImportCompensationResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "mode",
    "blockers",
    "importId",
    "organizerId",
    "accountRevision",
    "cohortIdsRemoved",
    "previewHash",
    "alreadyCompensated"
  ],
  "properties": {
    "mode": {
      "enum": [
        "archive_companion",
        "remove_cohorts",
        "blocked"
      ]
    },
    "blockers": {
      "type": "array",
      "maxItems": 32,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 96
      }
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
    "accountRevision": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 1
    },
    "cohortIdsRemoved": {
      "type": "array",
      "maxItems": 30,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180,
        "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
      }
    },
    "previewHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "alreadyCompensated": {
      "type": "boolean"
    }
  },
  "x-callable-aliases": [
    "adminPreviewSalesImportCompensation"
  ]
} as const;
