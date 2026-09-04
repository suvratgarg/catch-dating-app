/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const createOrganizerFormAssetIntentCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/create_organizer_form_asset_intent_response.schema.json",
  "title": "CreateOrganizerFormAssetIntentCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "assetId",
    "uploadToken",
    "uploadUrl",
    "uploadFields",
    "expiresAtMillis"
  ],
  "properties": {
    "assetId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "uploadToken": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{32,160}$"
    },
    "uploadUrl": {
      "type": "string",
      "format": "uri",
      "maxLength": 2000
    },
    "uploadFields": {
      "type": "object",
      "maxProperties": 30,
      "additionalProperties": {
        "type": "string",
        "maxLength": 4000
      }
    },
    "expiresAtMillis": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    }
  }
} as const;
