/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerEventCandidateReviewDecisionDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_event_candidate_review_decisions.schema.json",
  "title": "OrganizerEventCandidateReviewDecisionDocument",
  "description": "Latest admin event-candidate review decision stored at organizerEventCandidateReviewDecisions/{decisionId}. Raw provider event evidence and imported events are not stored here.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerEventCandidateReviewDecisions",
  "x-firestore-path": "organizerEventCandidateReviewDecisions/{decisionId}",
  "x-document-id-field": "decisionId",
  "x-owner": "adminDecideOrganizerEventCandidate callable",
  "required": [
    "schemaVersion",
    "decisionId",
    "candidateId",
    "decision",
    "decisionStatus",
    "checklist",
    "note",
    "reviewedByUid",
    "reviewedAt",
    "updatedAt",
    "importState"
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
    "candidateId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "decision": {
      "type": "string",
      "enum": [
        "approve_for_import",
        "hold",
        "reject"
      ]
    },
    "decisionStatus": {
      "type": "string",
      "enum": [
        "approved_for_import",
        "held",
        "rejected"
      ]
    },
    "checklist": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "identityReviewed",
        "sourceEventReviewed",
        "timeReviewed",
        "locationReviewed",
        "dedupeReviewed",
        "ownerSafeCopyReviewed",
        "importPolicyAcknowledged"
      ],
      "properties": {
        "identityReviewed": {
          "type": "boolean"
        },
        "sourceEventReviewed": {
          "type": "boolean"
        },
        "timeReviewed": {
          "type": "boolean"
        },
        "locationReviewed": {
          "type": "boolean"
        },
        "dedupeReviewed": {
          "type": "boolean"
        },
        "ownerSafeCopyReviewed": {
          "type": "boolean"
        },
        "importPolicyAcknowledged": {
          "type": "boolean"
        }
      }
    },
    "blockerResolutions": {
      "type": "array",
      "maxItems": 6,
      "items": {
        "title": "ExternalEventBlockerResolution",
        "description": "One explicit, event-scoped resolution or policy-backed waiver for a governed external-event import blocker.",
        "type": "object",
        "additionalProperties": false,
        "required": [
          "blockerCode",
          "outcome",
          "policyGapDecisionId",
          "note"
        ],
        "properties": {
          "blockerCode": {
            "type": "string",
            "enum": [
              "missing_exact_coordinates",
              "missing_end_time",
              "missing_location_detail",
              "requires_event_defaults_policy",
              "requires_owner_safe_copy_review",
              "duplicate_normalized_event_key"
            ]
          },
          "outcome": {
            "type": "string",
            "enum": [
              "resolved",
              "waived"
            ]
          },
          "policyGapDecisionId": {
            "type": [
              "string",
              "null"
            ],
            "minLength": 1,
            "maxLength": 180
          },
          "note": {
            "type": "string",
            "minLength": 1,
            "maxLength": 1000
          }
        },
        "allOf": [
          {
            "if": {
              "properties": {
                "outcome": {
                  "const": "waived"
                }
              }
            },
            "then": {
              "properties": {
                "policyGapDecisionId": {
                  "type": "string"
                }
              }
            }
          },
          {
            "if": {
              "properties": {
                "outcome": {
                  "const": "resolved"
                }
              }
            },
            "then": {
              "properties": {
                "policyGapDecisionId": {
                  "type": "null"
                }
              }
            }
          }
        ]
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
    "importState": {
      "type": "string",
      "enum": [
        "blocked_by_policy",
        "not_importable",
        "pending_import"
      ]
    }
  }
} as const;
