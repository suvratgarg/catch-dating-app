/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminReviseSalesQuoteCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_revise_sales_quote_payload.schema.json",
  "title": "commercial.quotes.revise request",
  "description": "Strict private Sales commercial request; current role, scope, revision and evidence policy are transactional.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "opportunityId",
    "requestId",
    "expectedRevision",
    "terms"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "opportunityId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "requestId": {
      "type": "string",
      "minLength": 8,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 1000000000
    },
    "terms": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "currency",
        "amountMinor",
        "billingCadence",
        "scope",
        "validUntil",
        "sourceFactRefs"
      ],
      "properties": {
        "currency": {
          "type": "string",
          "pattern": "^[A-Z]{3}$"
        },
        "amountMinor": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000000000
        },
        "billingCadence": {
          "enum": [
            "one_time",
            "monthly",
            "annual",
            "usage_based"
          ]
        },
        "scope": {
          "type": "string",
          "minLength": 1,
          "maxLength": 2000
        },
        "validUntil": {
          "type": "string",
          "format": "date-time"
        },
        "sourceFactRefs": {
          "type": "array",
          "minItems": 1,
          "maxItems": 20,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 96,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          }
        }
      }
    }
  }
} as const;
