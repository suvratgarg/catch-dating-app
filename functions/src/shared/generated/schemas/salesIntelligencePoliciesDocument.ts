/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesIntelligencePoliciesDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/sales_intelligence_policies.schema.json",
  "title": "SalesIntelligencePolicyDocument",
  "description": "Private, owner-reviewed, versioned fit and priority policy. No production weights are checked into source.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "salesIntelligencePolicies",
  "x-firestore-path": "salesIntelligencePolicies/{policyRecordId}",
  "x-document-id-field": "policyRecordId",
  "x-owner": "private Sales intelligence policy callable",
  "required": [
    "schemaVersion",
    "classification",
    "policyRecordId",
    "policyId",
    "revision",
    "version",
    "status",
    "factors",
    "priorityBands",
    "promptVersion",
    "playbookVersion",
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
    "policyRecordId": {
      "const": "current"
    },
    "policyId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "revision": {
      "type": "integer",
      "minimum": 1
    },
    "version": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "status": {
      "enum": [
        "active",
        "paused"
      ]
    },
    "factors": {
      "type": "array",
      "minItems": 7,
      "maxItems": 7,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "id",
          "weight",
          "claimKeys",
          "maxAgeDays"
        ],
        "properties": {
          "id": {
            "type": "string",
            "minLength": 1,
            "maxLength": 96,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          },
          "weight": {
            "type": "integer",
            "minimum": 1,
            "maximum": 100
          },
          "claimKeys": {
            "type": "array",
            "minItems": 1,
            "maxItems": 5,
            "uniqueItems": true,
            "items": {
              "enum": [
                "identity",
                "recurrence",
                "operation",
                "stack",
                "other"
              ]
            }
          },
          "maxAgeDays": {
            "type": "integer",
            "minimum": 1,
            "maximum": 365
          }
        }
      }
    },
    "priorityBands": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "high",
        "medium"
      ],
      "properties": {
        "high": {
          "type": "number",
          "minimum": 0,
          "maximum": 100
        },
        "medium": {
          "type": "number",
          "minimum": 0,
          "maximum": 100
        }
      }
    },
    "promptVersion": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "playbookVersion": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "updatedAt": {
      "type": "string",
      "format": "date-time"
    },
    "updatedBy": {
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
} as const;
