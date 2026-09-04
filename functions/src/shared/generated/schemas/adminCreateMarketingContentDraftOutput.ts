/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminCreateMarketingContentDraftCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/admin_create_marketing_content_draft_response.schema.json",
  "title": "Admin Create Marketing Content Draft Callable Response",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "draft",
    "bridge",
    "dashboardPath"
  ],
  "properties": {
    "draft": {
      "type": "object",
      "minProperties": 1,
      "additionalProperties": true
    },
    "bridge": {
      "type": "object",
      "minProperties": 1,
      "additionalProperties": true
    },
    "dashboardPath": {
      "type": "string",
      "minLength": 1,
      "maxLength": 260
    }
  }
} as const;
