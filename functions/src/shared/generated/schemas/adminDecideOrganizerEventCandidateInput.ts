/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminDecideOrganizerEventCandidateCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_decide_organizer_event_candidate_payload.schema.json",
  "title": "AdminDecideOrganizerEventCandidateCallablePayload",
  "description": "Callable payload accepted by adminDecideOrganizerEventCandidate. This records a manual admin review decision for a private external event candidate without importing the event.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "candidateId",
    "decision",
    "checklist",
    "blockerResolutions",
    "note"
  ],
  "properties": {
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
    }
  }
} as const;
