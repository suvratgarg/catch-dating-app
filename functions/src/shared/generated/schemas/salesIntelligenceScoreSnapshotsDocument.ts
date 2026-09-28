/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesIntelligenceScoreSnapshotDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/sales_intelligence_score_snapshots.schema.json",
  "title": "SalesIntelligenceScoreSnapshotDocument",
  "description": "Immutable reviewed-source fit snapshot. Unknown or disputed factors yield a null score and unranked priority.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "salesIntelligenceScoreSnapshots",
  "x-firestore-path": "salesIntelligenceScoreSnapshots/{snapshotId}",
  "x-document-id-field": "snapshotId",
  "x-owner": "private Sales intelligence score callable",
  "required": [
    "schemaVersion",
    "classification",
    "snapshotId",
    "organizerId",
    "accountRevision",
    "policyId",
    "policyRevision",
    "policyVersion",
    "sourceHash",
    "status",
    "score",
    "priority",
    "factors",
    "evaluatedAt"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "classification": {
      "const": "sales_private"
    },
    "snapshotId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "accountRevision": {
      "type": "integer",
      "minimum": 1
    },
    "policyId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "policyRevision": {
      "type": "integer",
      "minimum": 1
    },
    "policyVersion": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "sourceHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "status": {
      "enum": [
        "complete",
        "needs_research",
        "review_required"
      ]
    },
    "score": {
      "type": [
        "number",
        "null"
      ],
      "minimum": 0,
      "maximum": 100
    },
    "priority": {
      "enum": [
        "high",
        "medium",
        "low",
        "unranked"
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
          "factorId",
          "state",
          "value",
          "evidenceIds",
          "reason"
        ],
        "properties": {
          "factorId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 96,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          },
          "state": {
            "enum": [
              "known",
              "unknown",
              "disputed"
            ]
          },
          "value": {
            "type": [
              "integer",
              "null"
            ],
            "minimum": 0,
            "maximum": 5
          },
          "evidenceIds": {
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
          "reason": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 240
          }
        }
      }
    },
    "evaluatedAt": {
      "type": "string",
      "format": "date-time"
    }
  },
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
