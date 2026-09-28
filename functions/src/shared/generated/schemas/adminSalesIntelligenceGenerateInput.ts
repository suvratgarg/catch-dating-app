/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminSalesIntelligenceGenerateCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_sales_intelligence_generate_payload.schema.json",
  "title": "AdminGenerateSalesOutreachDraftPayload",
  "description": "Exact-retry zero-model Operations generation from approved private Sales source IDs. No prose, provider or send parameters.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "requestId",
    "sourceRequest"
  ],
  "properties": {
    "requestId": {
      "type": "string",
      "minLength": 8,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "sourceRequest": {
      "title": "AdminBuildSalesOutreachInputPayload",
      "description": "Selects only existing approved clause IDs; trusted server builds the Operations snapshot. No source prose is accepted from the caller.",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "organizerId",
        "contactId",
        "opportunityId",
        "observationIds",
        "capabilityIds",
        "referenceIds",
        "ctaIds",
        "channel",
        "purpose"
      ],
      "properties": {
        "organizerId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 96,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "contactId": {
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
        "observationIds": {
          "type": "array",
          "minItems": 1,
          "maxItems": 12,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 96,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          }
        },
        "capabilityIds": {
          "type": "array",
          "minItems": 1,
          "maxItems": 12,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 96,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          }
        },
        "referenceIds": {
          "type": "array",
          "maxItems": 8,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 96,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          }
        },
        "ctaIds": {
          "type": "array",
          "minItems": 1,
          "maxItems": 8,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 96,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          }
        },
        "channel": {
          "enum": [
            "email",
            "message"
          ]
        },
        "purpose": {
          "enum": [
            "first_message",
            "follow_up"
          ]
        },
        "priorActivityId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 96,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        }
      },
      "definitions": {
        "id": {
          "type": "string",
          "minLength": 1,
          "maxLength": 96,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        }
      }
    }
  }
} as const;
