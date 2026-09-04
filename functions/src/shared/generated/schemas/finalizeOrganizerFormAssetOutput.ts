/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const finalizeOrganizerFormAssetCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/finalize_organizer_form_asset_response.schema.json",
  "title": "FinalizeOrganizerFormAssetCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "assetId",
    "status",
    "sizeBytes"
  ],
  "properties": {
    "assetId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "status": {
      "type": "string",
      "enum": [
        "ready"
      ]
    },
    "sizeBytes": {
      "type": "integer",
      "minimum": 1,
      "maximum": 26214400
    }
  }
} as const;
