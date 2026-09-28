/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminListSalesImportHistoryResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/admin_sales_import_history_list_response.schema.json",
  "title": "AdminSalesImportHistoryListResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "records",
    "nextCursor"
  ],
  "properties": {
    "records": {
      "type": "array",
      "minItems": 0,
      "maxItems": 25,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "schemaVersion",
          "classification",
          "sourceId",
          "sourceRowId",
          "sourceContentHash",
          "importId",
          "organizerId",
          "promotionVersion",
          "recordId",
          "kind",
          "sourceColumn",
          "sourceValue",
          "occurredAt",
          "dateSourceColumn",
          "dateSourceValue",
          "contentHash",
          "recordedAt",
          "recordedBy",
          "providerConfirmed",
          "currentFitAuthority",
          "contactAuthority",
          "sendAuthority",
          "relativeChronology",
          "dateCertainty"
        ],
        "properties": {
          "schemaVersion": {
            "const": 1
          },
          "classification": {
            "const": "sales_private"
          },
          "sourceId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 96,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          },
          "sourceRowId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 96,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          },
          "sourceContentHash": {
            "type": "string",
            "pattern": "^[a-f0-9]{64}$"
          },
          "importId": {
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
          "promotionVersion": {
            "type": "string",
            "minLength": 1,
            "maxLength": 96,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          },
          "recordId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 96,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          },
          "kind": {
            "enum": [
              "activity",
              "observation",
              "benchmark"
            ]
          },
          "sourceColumn": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160
          },
          "sourceValue": {
            "type": "string",
            "minLength": 1,
            "maxLength": 2000
          },
          "occurredAt": {
            "anyOf": [
              {
                "type": "string",
                "format": "date-time",
                "maxLength": 48
              },
              {
                "type": "null"
              }
            ]
          },
          "dateSourceColumn": {
            "anyOf": [
              {
                "type": "string",
                "minLength": 1,
                "maxLength": 160
              },
              {
                "type": "null"
              }
            ]
          },
          "dateSourceValue": {
            "anyOf": [
              {
                "type": "string",
                "minLength": 1,
                "maxLength": 160
              },
              {
                "type": "null"
              }
            ]
          },
          "contentHash": {
            "type": "string",
            "pattern": "^[a-f0-9]{64}$"
          },
          "recordedAt": {
            "type": "string",
            "format": "date-time",
            "maxLength": 48
          },
          "recordedBy": {
            "type": "string",
            "minLength": 1,
            "maxLength": 96,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          },
          "providerConfirmed": {
            "const": false
          },
          "currentFitAuthority": {
            "const": false
          },
          "contactAuthority": {
            "const": false
          },
          "sendAuthority": {
            "const": false
          },
          "relativeChronology": {
            "enum": [
              "first_touch",
              "last_touch",
              "unspecified"
            ]
          },
          "dateCertainty": {
            "enum": [
              "source_exact",
              "unknown"
            ]
          }
        }
      }
    },
    "nextCursor": {
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
    }
  },
  "x-callable-aliases": [
    "adminListSalesImportHistory"
  ]
} as const;
