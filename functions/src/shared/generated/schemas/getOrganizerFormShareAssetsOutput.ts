/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getOrganizerFormShareAssetsCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/get_organizer_form_share_assets_response.schema.json",
  "title": "GetOrganizerFormShareAssetsCallableResponse",
  "description": "Canonical URL and safe responsive embed snippet.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "canonicalUrl",
    "embedUrl",
    "embedSnippet"
  ],
  "properties": {
    "canonicalUrl": {
      "type": "string",
      "format": "uri",
      "maxLength": 2000
    },
    "embedUrl": {
      "type": "string",
      "format": "uri",
      "maxLength": 2000
    },
    "embedSnippet": {
      "type": "string",
      "minLength": 1,
      "maxLength": 4000
    }
  }
} as const;
