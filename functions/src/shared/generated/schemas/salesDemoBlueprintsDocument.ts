/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesDemoBlueprintsDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/sales_demo_blueprints.schema.json",
  "title": "SalesDemoBlueprintDocument",
  "description": "Private reviewed plan; only its preview object can reach an anonymous invitation view.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "classification",
    "blueprintId",
    "revision",
    "state",
    "organizerId",
    "candidateId",
    "opportunityId",
    "capability",
    "capabilityRevision",
    "evidenceRevision",
    "seedVersion",
    "formCapabilityReview",
    "fieldMappings",
    "preview",
    "reviewedByUid",
    "reviewedAt",
    "updatedAt",
    "updatedByUid"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "classification": {
      "const": "sales_private"
    },
    "blueprintId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "revision": {
      "type": "integer",
      "minimum": 1
    },
    "state": {
      "enum": [
        "draft",
        "reviewed",
        "withdrawn"
      ]
    },
    "organizerId": {
      "anyOf": [
        {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        },
        {
          "type": "null"
        }
      ]
    },
    "candidateId": {
      "anyOf": [
        {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        },
        {
          "type": "null"
        }
      ]
    },
    "opportunityId": {
      "anyOf": [
        {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        },
        {
          "type": "null"
        }
      ]
    },
    "capability": {
      "const": "synthetic_forms_v1"
    },
    "capabilityRevision": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "evidenceRevision": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "seedVersion": {
      "const": 1
    },
    "formCapabilityReview": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "questionTypes",
        "branching",
        "requiredFields",
        "scoringApproval",
        "uploads"
      ],
      "properties": {
        "questionTypes": {
          "enum": [
            "exact",
            "manual",
            "retained",
            "unsupported"
          ]
        },
        "branching": {
          "enum": [
            "exact",
            "manual",
            "retained",
            "unsupported"
          ]
        },
        "requiredFields": {
          "enum": [
            "exact",
            "manual",
            "retained",
            "unsupported"
          ]
        },
        "scoringApproval": {
          "enum": [
            "exact",
            "manual",
            "retained",
            "unsupported"
          ]
        },
        "uploads": {
          "enum": [
            "exact",
            "manual",
            "retained",
            "unsupported"
          ]
        }
      }
    },
    "fieldMappings": {
      "type": "array",
      "maxItems": 30,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "sourceField",
          "catchField",
          "disposition"
        ],
        "properties": {
          "sourceField": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160
          },
          "catchField": {
            "anyOf": [
              {
                "type": "string",
                "minLength": 1,
                "maxLength": 160
              },
              {
                "type": "null"
              }
            ]
          },
          "disposition": {
            "enum": [
              "exact",
              "manual",
              "retained",
              "unsupported"
            ]
          }
        }
      }
    },
    "preview": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "brandName",
        "headline",
        "scenario",
        "steps",
        "retainedTools",
        "limitations",
        "cta"
      ],
      "properties": {
        "brandName": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160
        },
        "headline": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160
        },
        "scenario": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160
        },
        "steps": {
          "type": "array",
          "minItems": 3,
          "maxItems": 3,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160
          }
        },
        "retainedTools": {
          "type": "array",
          "maxItems": 8,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160
          }
        },
        "limitations": {
          "type": "array",
          "minItems": 1,
          "maxItems": 8,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160
          }
        },
        "cta": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160
        }
      }
    },
    "reviewedByUid": {
      "anyOf": [
        {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        },
        {
          "type": "null"
        }
      ]
    },
    "reviewedAt": {
      "anyOf": [
        {
          "type": "string",
          "format": "date-time"
        },
        {
          "type": "null"
        }
      ]
    },
    "updatedAt": {
      "type": "string",
      "format": "date-time"
    },
    "updatedByUid": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    }
  },
  "definitions": {
    "id": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "text": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160
    },
    "disposition": {
      "enum": [
        "exact",
        "manual",
        "retained",
        "unsupported"
      ]
    }
  },
  "x-firestore-collection": "salesDemoBlueprints",
  "x-firestore-path": "salesDemoBlueprints/{blueprintId}",
  "x-document-id-field": "blueprintId",
  "x-owner": "sales demo admin callable"
} as const;
