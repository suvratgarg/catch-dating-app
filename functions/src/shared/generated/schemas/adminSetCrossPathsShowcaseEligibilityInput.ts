/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminSetCrossPathsShowcaseEligibilityCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_set_cross_paths_showcase_eligibility_payload.schema.json",
  "title": "AdminSetCrossPathsShowcaseEligibilityCallablePayload",
  "description": "Callable payload for an audited human Cross Paths showcase eligibility decision.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "uid",
    "status",
    "reviewChecklist",
    "reviewNote"
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
    "reviewChecklist": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "primaryPortraitClear",
        "profileRepresentsCurrentMember",
        "showcasePolicyReviewed"
      ],
      "properties": {
        "primaryPortraitClear": {
          "type": "boolean"
        },
        "profileRepresentsCurrentMember": {
          "type": "boolean"
        },
        "showcasePolicyReviewed": {
          "type": "boolean"
        }
      }
    },
    "reviewNote": {
      "type": "string",
      "minLength": 1,
      "maxLength": 1000
    }
  }
} as const;
