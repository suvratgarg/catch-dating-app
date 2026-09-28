/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesOpportunityDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/sales_opportunities.schema.json",
  "title": "SalesOpportunityDocument",
  "description": "Private sales pipeline stage, independent of public organizer status.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "salesOpportunities",
  "x-firestore-path": "salesOpportunities/{opportunityId}",
  "x-owner": "private Sales opportunity service",
  "required": [
    "schemaVersion",
    "classification",
    "opportunityId",
    "organizerId",
    "revision",
    "motion",
    "stage",
    "ownerUid",
    "nextStep",
    "nextStepAt",
    "stageEnteredAt",
    "createdAt",
    "updatedAt",
    "updatedBy"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "classification": {
      "const": "sales_private"
    },
    "opportunityId": {
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
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000000000
    },
    "motion": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160
    },
    "stage": {
      "enum": [
        "new_enquiry",
        "ready_to_contact",
        "contacted",
        "in_conversation",
        "demo_arranged",
        "demo_completed",
        "pilot_agreed",
        "pilot_running",
        "commercial_discussion",
        "closed_won",
        "closed_lost"
      ]
    },
    "ownerUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "nextStep": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 0,
          "maxLength": 320
        },
        {
          "type": "null"
        }
      ]
    },
    "nextStepAt": {
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
    "stageEnteredAt": {
      "type": "string",
      "format": "date-time",
      "maxLength": 48
    },
    "createdAt": {
      "type": "string",
      "format": "date-time",
      "maxLength": 48
    },
    "updatedAt": {
      "type": "string",
      "format": "date-time",
      "maxLength": 48
    },
    "updatedBy": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  },
  "x-document-id-field": "opportunityId"
} as const;
