/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesEvidenceProposalsDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/sales_evidence_proposals.schema.json",
  "title": "SalesEvidenceProposalDocument",
  "x-firestore-collection": "salesEvidenceProposals",
  "x-firestore-path": "salesEvidenceProposals/{proposalId}",
  "x-owner": "private Sales evidence service",
  "x-document-id-field": "proposalId",
  "description": "Private suggestions, isolated from employee-reviewed evidence and qualification.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "classification",
    "proposalId",
    "organizerId",
    "revision",
    "status",
    "evidence",
    "createdAt",
    "createdBy",
    "clientId",
    "clientAuthUid",
    "delegationId",
    "reviewedAt",
    "reviewerUid",
    "reviewReason",
    "promotedEvidenceId"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "classification": {
      "const": "sales_private"
    },
    "proposalId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "revision": {
      "type": "integer",
      "minimum": 1
    },
    "status": {
      "enum": [
        "pending",
        "accepted",
        "rejected"
      ]
    },
    "evidence": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "organizerId",
        "claimKey",
        "sourceType",
        "sourceRef",
        "observedAt",
        "confidence"
      ],
      "properties": {
        "organizerId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 96,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "contactId": {
          "anyOf": [
            {
              "type": "string",
              "minLength": 1,
              "maxLength": 96,
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
          "type": "string",
          "minLength": 1,
          "maxLength": 96,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
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
          "format": "date-time"
        },
        "validThrough": {
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
        "confidence": {
          "enum": [
            "high",
            "medium",
            "low"
          ]
        },
        "normalizedValue": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 500
        },
        "excerpt": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 500
        }
      }
    },
    "createdAt": {
      "type": "string",
      "format": "date-time"
    },
    "createdBy": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "clientId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    },
    "clientAuthUid": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    },
    "delegationId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
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
    "reviewerUid": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    },
    "reviewReason": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 2000
    },
    "promotedEvidenceId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    }
  }
} as const;
