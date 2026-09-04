/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventIntakeReviewDecisionDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_intake_review_decisions.schema.json",
  "title": "EventIntakeReviewDecisionDocument",
  "description": "Latest admin review decision stored at eventIntakeReviewDecisions/{decisionId}. Source artifacts, marketing content, imported events, and canonical events are not stored here.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventIntakeReviewDecisions",
  "x-firestore-path": "eventIntakeReviewDecisions/{decisionId}",
  "x-document-id-field": "decisionId",
  "x-owner": "adminRecordEventIntakeReviewDecision callable",
  "required": [
    "schemaVersion",
    "decisionId",
    "targetType",
    "targetId",
    "decision",
    "decisionStatus",
    "runId",
    "note",
    "checklist",
    "edits",
    "reviewedByUid",
    "reviewedAt",
    "updatedAt",
    "effect"
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
    "targetType": {
      "type": "string",
      "enum": [
        "source_profile",
        "query_template",
        "run_plan",
        "source_result",
        "event_candidate"
      ]
    },
    "targetId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "decision": {
      "type": "string",
      "enum": [
        "approve",
        "needs_changes",
        "hold",
        "reject"
      ]
    },
    "decisionStatus": {
      "type": "string",
      "enum": [
        "approved",
        "needs_changes",
        "held",
        "rejected"
      ]
    },
    "runId": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 180
    },
    "note": {
      "type": "string",
      "minLength": 1,
      "maxLength": 2000
    },
    "checklist": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "sourceReviewed",
        "dateReviewed",
        "venueReviewed",
        "copyReviewed",
        "rightsReviewed",
        "noCatchHostingImplied"
      ],
      "properties": {
        "sourceReviewed": {
          "type": "boolean"
        },
        "dateReviewed": {
          "type": "boolean"
        },
        "venueReviewed": {
          "type": "boolean"
        },
        "copyReviewed": {
          "type": "boolean"
        },
        "rightsReviewed": {
          "type": "boolean"
        },
        "noCatchHostingImplied": {
          "type": "boolean"
        }
      }
    },
    "edits": {
      "type": "object",
      "description": "Changed fields only. Each entry freezes its reviewed before and after value.",
      "maxProperties": 40,
      "additionalProperties": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "before",
          "after"
        ],
        "properties": {
          "before": {},
          "after": {}
        }
      }
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
    "effect": {
      "type": "string",
      "const": "decision_only_no_publish"
    }
  }
} as const;
