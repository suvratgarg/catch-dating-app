/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const outreachDraftingSelectionSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/operations/outreach_drafting_selection.schema.json",
  "title": "OutreachDraftingSelection",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "contactId",
    "opportunityId",
    "language",
    "observationId",
    "capabilityId",
    "referenceId",
    "ctaId",
    "reasonToBlock",
    "omittedIds"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1
    },
    "contactId": {
      "type": "string",
      "minLength": 1
    },
    "opportunityId": {
      "type": "string",
      "minLength": 1
    },
    "language": {
      "const": "en"
    },
    "observationId": {
      "type": [
        "string",
        "null"
      ]
    },
    "capabilityId": {
      "type": [
        "string",
        "null"
      ]
    },
    "referenceId": {
      "type": [
        "string",
        "null"
      ]
    },
    "ctaId": {
      "type": [
        "string",
        "null"
      ]
    },
    "reasonToBlock": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 200
    },
    "omittedIds": {
      "type": "array",
      "maxItems": 20,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 160
      }
    }
  }
} as const;
