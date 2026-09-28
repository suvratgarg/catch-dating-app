/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesEvidenceDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/sales_evidence.schema.json",
  "title": "SalesEvidenceDocument",
  "description": "Reviewed source lineage for Sales claims; not provider consent or ownership verification.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "salesEvidence",
  "x-firestore-path": "salesEvidence/{evidenceId}",
  "x-owner": "private Sales evidence service",
  "required": [
    "schemaVersion",
    "classification",
    "evidenceId",
    "organizerId",
    "contactId",
    "claimKey",
    "signalId",
    "sourceType",
    "sourceRef",
    "observedAt",
    "validThrough",
    "confidence",
    "normalizedValue",
    "excerpt",
    "reviewedAt",
    "reviewerUid",
    "createdAt",
    "createdBy"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "classification": {
      "const": "sales_private"
    },
    "evidenceId": {
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
    "contactId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        {
          "type": "null"
        }
      ]
    },
    "claimKey": {
      "enum": [
        "identity",
        "recurrence",
        "operation",
        "stack",
        "other"
      ]
    },
    "signalId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        {
          "type": "null"
        }
      ]
    },
    "sourceType": {
      "enum": [
        "first_party",
        "public_web",
        "human_note",
        "import_artifact"
      ]
    },
    "sourceRef": {
      "type": "string",
      "minLength": 1,
      "maxLength": 320
    },
    "observedAt": {
      "type": "string",
      "format": "date-time",
      "maxLength": 48
    },
    "validThrough": {
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
    "confidence": {
      "enum": [
        "high",
        "medium",
        "low"
      ]
    },
    "normalizedValue": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 0,
          "maxLength": 500
        },
        {
          "type": "null"
        }
      ]
    },
    "excerpt": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 0,
          "maxLength": 500
        },
        {
          "type": "null"
        }
      ]
    },
    "reviewedAt": {
      "type": "string",
      "format": "date-time",
      "maxLength": 48
    },
    "reviewerUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "createdAt": {
      "type": "string",
      "format": "date-time",
      "maxLength": 48
    },
    "createdBy": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  },
  "x-document-id-field": "evidenceId",
  "allOf": [
    {
      "if": {
        "properties": {
          "claimKey": {
            "const": "operation"
          }
        }
      },
      "then": {
        "properties": {
          "signalId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          }
        }
      }
    }
  ]
} as const;
