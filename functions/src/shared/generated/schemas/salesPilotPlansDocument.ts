/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesPilotPlansDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/sales_pilot_plans.schema.json",
  "title": "salesPilotPlans document",
  "description": "Private revisioned pilot scope; no revenue or product activation authority.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "salesPilotPlans",
  "x-firestore-path": "salesPilotPlans/{opportunityId}",
  "x-owner": "private Sales commercial service",
  "required": [
    "schemaVersion",
    "classification",
    "organizerId",
    "opportunityId",
    "revision",
    "status",
    "workflowId",
    "objective",
    "successMeasures",
    "startsAt",
    "endsAt",
    "reviewEvidence",
    "outcomeEvidence",
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
    "revision": {
      "type": "integer",
      "minimum": 1
    },
    "status": {
      "enum": [
        "draft",
        "reviewed",
        "active",
        "completed",
        "cancelled"
      ]
    },
    "workflowId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "objective": {
      "type": "string",
      "minLength": 1,
      "maxLength": 1000
    },
    "successMeasures": {
      "type": "array",
      "minItems": 1,
      "maxItems": 8,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 240
      }
    },
    "startsAt": {
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
    "endsAt": {
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
    "reviewEvidence": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "evidenceId",
            "sourceRef",
            "contentHash",
            "observedAt"
          ],
          "properties": {
            "evidenceId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "sourceRef": {
              "type": "string",
              "minLength": 1,
              "maxLength": 512
            },
            "contentHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "observedAt": {
              "type": "string",
              "format": "date-time",
              "maxLength": 48
            }
          }
        },
        {
          "type": "null"
        }
      ]
    },
    "outcomeEvidence": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "evidenceId",
            "sourceRef",
            "contentHash",
            "observedAt"
          ],
          "properties": {
            "evidenceId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "sourceRef": {
              "type": "string",
              "minLength": 1,
              "maxLength": 512
            },
            "contentHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "observedAt": {
              "type": "string",
              "format": "date-time",
              "maxLength": 48
            }
          }
        },
        {
          "type": "null"
        }
      ]
    },
    "updatedAt": {
      "type": "string",
      "format": "date-time",
      "maxLength": 48
    },
    "updatedBy": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    }
  },
  "x-document-id-field": "opportunityId"
} as const;
