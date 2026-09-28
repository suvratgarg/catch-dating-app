/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminApplySalesImportCompensationResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/admin_sales_import_compensation_apply_response.schema.json",
  "title": "AdminApplySalesImportCompensationResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "importId",
    "organizerId",
    "status",
    "receipt"
  ],
  "properties": {
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
    "status": {
      "enum": [
        "compensated",
        "already_compensated"
      ]
    },
    "mode": {
      "enum": [
        "archive_companion",
        "remove_cohorts"
      ]
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
    "accountRevision": {
      "type": "integer",
      "minimum": 1
    },
    "receipt": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "requestId",
        "revision"
      ],
      "properties": {
        "requestId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "revision": {
          "type": [
            "integer",
            "null"
          ],
          "minimum": 1
        }
      }
    }
  },
  "x-callable-aliases": [
    "adminApplySalesImportCompensation"
  ]
} as const;
