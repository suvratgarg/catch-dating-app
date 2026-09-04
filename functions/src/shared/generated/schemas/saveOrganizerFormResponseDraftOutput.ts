/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const saveOrganizerFormResponseDraftCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/save_organizer_form_response_draft_response.schema.json",
  "title": "SaveOrganizerFormResponseDraftCallableResponse",
  "description": "Saved draft revision and expiry.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "draftId",
    "revision",
    "expiresAtMillis"
  ],
  "properties": {
    "draftId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "expiresAtMillis": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    }
  }
} as const;
