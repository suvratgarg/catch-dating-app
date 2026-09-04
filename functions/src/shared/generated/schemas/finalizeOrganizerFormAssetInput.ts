/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const finalizeOrganizerFormAssetCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/finalize_organizer_form_asset_payload.schema.json",
  "title": "FinalizeOrganizerFormAssetCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "draftId",
    "draftToken",
    "assetId",
    "uploadToken"
  ],
  "properties": {
    "draftId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "draftToken": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^[A-Za-z0-9_-]{32,160}$"
    },
    "assetId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "uploadToken": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{32,160}$"
    }
  }
} as const;
