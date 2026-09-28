/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminSalesIntelligenceReviewCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_sales_intelligence_review_payload.schema.json",
  "title": "AdminSalesIntelligenceReviewPayload",
  "description": "Closed review and manual-copy requests. Each callable accepts only its own variant; none grants send authority.",
  "oneOf": [
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "requestId",
        "clauseId",
        "expectedRevision",
        "decision"
      ],
      "properties": {
        "requestId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 96,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "clauseId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 96,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "expectedRevision": {
          "type": "integer",
          "minimum": 0
        },
        "decision": {
          "enum": [
            "approve",
            "withdraw"
          ]
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "requestId",
        "draftId",
        "expectedContentHash",
        "factualValidity",
        "tone",
        "channelReadiness"
      ],
      "properties": {
        "requestId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 96,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "draftId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 96,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "expectedContentHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "factualValidity": {
          "const": "verified"
        },
        "tone": {
          "const": "approved"
        },
        "channelReadiness": {
          "const": "manual_copy_only"
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "requestId",
        "draftId",
        "expectedContentHash"
      ],
      "properties": {
        "requestId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 96,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "draftId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 96,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "expectedContentHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        }
      }
    }
  ],
  "definitions": {
    "id": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "hash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    }
  }
} as const;
