/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminListCrossPathsShowcaseCandidatesCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_list_cross_paths_showcase_candidates_payload.schema.json",
  "title": "AdminListCrossPathsShowcaseCandidatesCallablePayload",
  "description": "Callable payload for a bounded, role-gated Cross Paths showcase review queue.",
  "type": "object",
  "additionalProperties": false,
  "properties": {
    "uid": {
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
    "status": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        "all",
        "eligible",
        "needsReview",
        "paused",
        null
      ]
    },
    "marketId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 120,
          "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
        },
        {
          "type": "null"
        }
      ]
    },
    "cursor": {
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
    "limit": {
      "type": "integer",
      "minimum": 1,
      "maximum": 50
    }
  }
} as const;
