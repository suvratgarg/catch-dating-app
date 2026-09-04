/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getOrganizerFormEditorCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/get_organizer_form_editor_payload.schema.json",
  "title": "GetOrganizerFormEditorCallablePayload",
  "description": "Gets one manager-authorized form and its editable draft.",
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
