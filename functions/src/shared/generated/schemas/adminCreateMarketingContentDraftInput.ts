/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminCreateMarketingContentDraftCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_create_marketing_content_draft_payload.schema.json",
  "title": "Admin Create Marketing Content Draft Callable Payload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "draftType"
  ],
  "properties": {
    "draftType": {
      "type": "string",
      "enum": [
        "event_highlights",
        "feature_explainer"
      ]
    },
    "cityId": {
      "anyOf": [
        {
          "type": "string",
          "pattern": "^[a-z0-9-]{2,60}$"
        },
        {
          "type": "null"
        }
      ]
    },
    "weekStart": {
      "anyOf": [
        {
          "type": "string",
          "format": "date"
        },
        {
          "type": "null"
        }
      ]
    },
    "sourceRecommendationSetId": {
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
    "title": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 140
        },
        {
          "type": "null"
        }
      ]
    }
  }
} as const;
