/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerPolicyGapReviewDecisionDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_policy_gap_review_decisions.schema.json",
  "title": "OrganizerPolicyGapReviewDecisionDocument",
  "description": "Latest admin/product policy-gap review decision stored at organizerPolicyGapReviewDecisions/{decisionId}. These decisions are review state only and do not enable organizer crawls, provider lookups, event imports, defaults, or naming migrations.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerPolicyGapReviewDecisions",
  "x-firestore-path": "organizerPolicyGapReviewDecisions/{decisionId}",
  "x-document-id-field": "decisionId",
  "x-owner": "adminDecideOrganizerPolicyGap callable",
  "required": [
    "schemaVersion",
    "decisionId",
    "gapId",
    "decision",
    "decisionStatus",
    "requiredInputsReviewed",
    "checklist",
    "note",
    "reviewedByUid",
    "reviewedAt",
    "updatedAt",
    "operationalState"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "decisionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "gapId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160
    },
    "decision": {
      "type": "string",
      "enum": [
        "accept",
        "hold",
        "reject"
      ]
    },
    "decisionStatus": {
      "type": "string",
      "enum": [
        "accepted",
        "held",
        "rejected"
      ]
    },
    "requiredInputsReviewed": {
      "type": "array",
      "maxItems": 20,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 240
      },
      "uniqueItems": true
    },
    "checklist": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "requiredInputsReviewed",
        "costAndSafetyReviewed",
        "implementationOwnerReviewed",
        "behaviorStillDisabledAcknowledged"
      ],
      "properties": {
        "requiredInputsReviewed": {
          "type": "boolean"
        },
        "costAndSafetyReviewed": {
          "type": "boolean"
        },
        "implementationOwnerReviewed": {
          "type": "boolean"
        },
        "behaviorStillDisabledAcknowledged": {
          "type": "boolean"
        }
      }
    },
    "note": {
      "type": "string",
      "minLength": 1,
      "maxLength": 1000
    },
    "reviewedByUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "reviewedAt": {
      "type": "object",
      "description": "Serialized Firestore Timestamp fixture shape.",
      "x-firestore-type": "timestamp",
      "additionalProperties": false,
      "required": [
        "_seconds",
        "_nanoseconds"
      ],
      "properties": {
        "_seconds": {
          "type": "integer"
        },
        "_nanoseconds": {
          "type": "integer",
          "minimum": 0,
          "maximum": 999999999
        }
      }
    },
    "updatedAt": {
      "type": "object",
      "description": "Serialized Firestore Timestamp fixture shape.",
      "x-firestore-type": "timestamp",
      "additionalProperties": false,
      "required": [
        "_seconds",
        "_nanoseconds"
      ],
      "properties": {
        "_seconds": {
          "type": "integer"
        },
        "_nanoseconds": {
          "type": "integer",
          "minimum": 0,
          "maximum": 999999999
        }
      }
    },
    "operationalState": {
      "type": "string",
      "enum": [
        "blocked_until_policy_encoded",
        "not_approved"
      ]
    }
  }
} as const;
