/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminRecordMarketingReviewDecisionCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_record_marketing_review_decision_payload.schema.json",
  "title": "Admin Record Marketing Review Decision Callable Payload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "targetType",
    "targetId",
    "decision",
    "note"
  ],
  "properties": {
    "targetType": {
      "type": "string",
      "enum": [
        "source_profile",
        "query_template",
        "run_plan",
        "source_result",
        "event_candidate",
        "recommendation_item",
        "recommendation_set",
        "content_draft"
      ]
    },
    "targetId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 500
    },
    "decision": {
      "type": "string",
      "enum": [
        "approve",
        "needs_changes",
        "hold",
        "reject",
        "export_ready"
      ]
    },
    "runId": {
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
    "note": {
      "type": "string",
      "minLength": 1,
      "maxLength": 2000
    },
    "edits": {
      "type": "object",
      "additionalProperties": true
    },
    "checklist": {
      "type": "object",
      "additionalProperties": false,
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
    }
  },
  "definitions": {
    "checklist": {
      "type": "object",
      "additionalProperties": false,
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
    }
  }
} as const;
