/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminListSalesOutreachDraftsResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/admin_sales_outreach_list_response.schema.json",
  "title": "AdminListSalesOutreachDraftsResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "rows"
  ],
  "properties": {
    "rows": {
      "type": "array",
      "maxItems": 50,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "draftId",
          "contactId",
          "opportunityId",
          "subject",
          "status",
          "contentHash",
          "createdAt",
          "reviewedAt"
        ],
        "properties": {
          "draftId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          },
          "contactId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          },
          "opportunityId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          },
          "subject": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 300
          },
          "status": {
            "enum": [
              "pending_review",
              "approved"
            ]
          },
          "contentHash": {
            "type": "string",
            "pattern": "^[a-f0-9]{64}$"
          },
          "createdAt": {
            "type": "string",
            "format": "date-time"
          },
          "reviewedAt": {
            "type": [
              "string",
              "null"
            ],
            "format": "date-time"
          }
        }
      }
    }
  },
  "definitions": {
    "id": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    }
  },
  "x-callable-aliases": [
    "adminListSalesOutreachDrafts"
  ]
} as const;
