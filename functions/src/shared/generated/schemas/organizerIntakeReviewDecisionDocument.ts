/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerIntakeReviewDecisionDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_intake_review_decisions.schema.json",
  "title": "OrganizerIntakeReviewDecisionDocument",
  "description": "Latest admin review decision stored at organizerIntakeReviewDecisions/{entityId}. Candidate evidence remains in operationRuns and operationWorkItems.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerIntakeReviewDecisions",
  "x-firestore-path": "organizerIntakeReviewDecisions/{entityId}",
  "x-document-id-field": "entityId",
  "x-owner": "adminDecideOrganizerIntake callable",
  "required": [
    "schemaVersion",
    "entityId",
    "decision",
    "decisionStatus",
    "publishStatus",
    "indexStatus",
    "appVisibility",
    "checklist",
    "note",
    "reviewedByUid",
    "reviewedAt",
    "updatedAt",
    "projectionState"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "entityId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "decision": {
      "type": "string",
      "enum": [
        "approve_public",
        "hold",
        "suppress"
      ]
    },
    "decisionStatus": {
      "type": "string",
      "enum": [
        "approved_public",
        "held",
        "suppressed"
      ]
    },
    "publishStatus": {
      "type": "string",
      "enum": [
        "draft",
        "published",
        "suppressed"
      ]
    },
    "indexStatus": {
      "type": "string",
      "enum": [
        "noindex",
        "indexed"
      ]
    },
    "appVisibility": {
      "type": "string",
      "enum": [
        "hidden",
        "discoverable"
      ]
    },
    "checklist": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "identityReviewed",
        "surfaceInventoryReviewed",
        "ownerSafeCopyReviewed",
        "marketScopeReviewed",
        "mediaRightsReviewed",
        "crawlDisabledReviewed"
      ],
      "properties": {
        "identityReviewed": {
          "type": "boolean"
        },
        "surfaceInventoryReviewed": {
          "type": "boolean"
        },
        "ownerSafeCopyReviewed": {
          "type": "boolean"
        },
        "marketScopeReviewed": {
          "type": "boolean"
        },
        "mediaRightsReviewed": {
          "type": "boolean"
        },
        "crawlDisabledReviewed": {
          "type": "boolean"
        },
        "manualReportsReviewed": {
          "type": "boolean",
          "description": "True when the reviewer explicitly inspected manual reports that have no stored source artifact. Projection replay decides when this acknowledgement is required."
        },
        "claimTargetReviewed": {
          "type": "boolean"
        },
        "takedownPathReviewed": {
          "type": "boolean"
        },
        "impersonationReviewed": {
          "type": "boolean"
        },
        "operatingStatusReviewed": {
          "type": "boolean"
        },
        "eventAccuracyReviewed": {
          "type": "boolean"
        },
        "unclaimedAffordancesReviewed": {
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
    "projectionState": {
      "type": "string",
      "enum": [
        "pending_static_generation",
        "not_projectable"
      ]
    }
  }
} as const;
