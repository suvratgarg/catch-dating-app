/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getOrganizerFormShareAssetsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/get_organizer_form_share_assets_payload.schema.json",
  "title": "GetOrganizerFormShareAssetsCallablePayload",
  "description": "Returns canonical distribution configuration for one published form.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "formId"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "formId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
