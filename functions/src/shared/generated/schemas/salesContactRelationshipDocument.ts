/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesContactRelationshipDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/sales_contact_relationships.schema.json",
  "title": "SalesContactRelationshipDocument",
  "description": "Organizer-scoped role, endpoints, and human draft review. Draft review never grants send authority.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "salesContactRelationships",
  "x-firestore-path": "salesContactRelationships/{relationshipId}",
  "x-owner": "private Sales contact service",
  "required": [
    "schemaVersion",
    "classification",
    "relationshipId",
    "contactId",
    "organizerId",
    "revision",
    "role",
    "decisionInfluence",
    "primary",
    "contactabilityStatus",
    "contactabilityReason",
    "contactabilityAt",
    "contactabilityBy",
    "draftReviewEvidenceId",
    "sendAuthority",
    "endpoints",
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
    "relationshipId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "contactId": {
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
    "role": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160
    },
    "decisionInfluence": {
      "enum": [
        "unknown",
        "decision_maker",
        "influencer",
        "operator"
      ]
    },
    "primary": {
      "type": "boolean"
    },
    "contactabilityStatus": {
      "enum": [
        "unknown",
        "draft_reviewed",
        "held",
        "suppressed"
      ]
    },
    "contactabilityReason": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 0,
          "maxLength": 2000
        },
        {
          "type": "null"
        }
      ]
    },
    "contactabilityAt": {
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
    "contactabilityBy": {
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
    "draftReviewEvidenceId": {
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
    "sendAuthority": {
      "const": false
    },
    "endpoints": {
      "type": "array",
      "minItems": 0,
      "maxItems": 3,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "kind",
          "value",
          "verificationStatus"
        ],
        "properties": {
          "kind": {
            "enum": [
              "email",
              "phone"
            ]
          },
          "value": {
            "type": "string",
            "minLength": 3,
            "maxLength": 160
          },
          "verificationStatus": {
            "enum": [
              "unverified",
              "verified"
            ]
          },
          "evidenceId": {
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
          }
        }
      }
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
  "x-document-id-field": "relationshipId",
  "allOf": [
    {
      "if": {
        "properties": {
          "contactabilityStatus": {
            "const": "draft_reviewed"
          }
        }
      },
      "then": {
        "properties": {
          "draftReviewEvidenceId": {
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
