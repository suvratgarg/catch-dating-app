/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminGenerateSalesOutreachDraftResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/admin_sales_outreach_generate_response.schema.json",
  "title": "AdminGenerateSalesOutreachDraftResponse",
  "oneOf": [
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "status",
        "result",
        "idempotentReplay"
      ],
      "properties": {
        "status": {
          "const": "completed"
        },
        "result": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "draftId",
            "contentHash"
          ],
          "properties": {
            "draftId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160
            },
            "contentHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            }
          }
        },
        "idempotentReplay": {
          "type": "boolean"
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "status",
        "retryAfterSeconds"
      ],
      "properties": {
        "status": {
          "const": "running"
        },
        "retryAfterSeconds": {
          "type": "integer",
          "minimum": 1,
          "maximum": 60
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "status",
        "failure"
      ],
      "properties": {
        "status": {
          "const": "failed"
        },
        "failure": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 160
        }
      }
    }
  ],
  "x-callable-aliases": [
    "adminGenerateSalesOutreachDraft"
  ]
} as const;
