/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminRecordEventIntakeReviewDecisionCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_record_event_intake_review_decision_payload.schema.json",
  "title": "AdminRecordEventIntakeReviewDecisionCallablePayload",
  "description": "Callable payload accepted by adminRecordEventIntakeReviewDecision. This records a manual admin decision for private event-intake artifacts without publishing marketing content or creating canonical events.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "targetType",
    "targetId",
    "decision",
    "checklist",
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
    "edits": {
      "type": "object",
      "description": "Changed fields only. Each entry freezes the reviewed before and after values so extractor-learning and audit consumers can distinguish a correction from a whole-record resubmission.",
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
    }
  }
} as const;
