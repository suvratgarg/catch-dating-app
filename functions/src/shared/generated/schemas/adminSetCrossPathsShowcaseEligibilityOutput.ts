/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminSetCrossPathsShowcaseEligibilityCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/admin_set_cross_paths_showcase_eligibility_response.schema.json",
  "title": "AdminSetCrossPathsShowcaseEligibilityCallableResponse",
  "description": "Validated result of one audited Cross Paths showcase eligibility decision.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "uid",
    "status",
    "reasonCodes",
    "profileFingerprint",
    "ruleVersion",
    "reviewVersion",
    "reviewedAt"
  ],
  "properties": {
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "status": {
      "type": "string",
      "enum": [
        "eligible",
        "needsReview",
        "paused"
      ]
    },
    "reasonCodes": {
      "type": "array",
      "maxItems": 12,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "enum": [
          "insufficient_photos",
          "incomplete_prompts",
          "missing_relationship_goal",
          "broken_media",
          "photo_moderation_pending",
          "photo_moderation_rejected",
          "public_profile_missing",
          "profile_changed",
          "reviewer_hold",
          "manual_pause"
        ]
      }
    },
    "profileFingerprint": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "ruleVersion": {
      "type": "integer",
      "minimum": 1
    },
    "reviewVersion": {
      "type": "integer",
      "minimum": 1
    },
    "reviewedAt": {
      "type": "string",
      "format": "date-time"
    }
  }
} as const;
