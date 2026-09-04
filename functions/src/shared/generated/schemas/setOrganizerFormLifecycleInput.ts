/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const setOrganizerFormLifecycleCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/set_organizer_form_lifecycle_payload.schema.json",
  "title": "SetOrganizerFormLifecycleCallablePayload",
  "description": "Pauses, resumes, or archives one organizer form with an expected-state guard.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "formId",
    "expectedStatus",
    "action"
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
    },
    "expectedStatus": {
      "type": "string",
      "enum": [
        "draft",
        "published",
        "paused",
        "archived"
      ]
    },
    "action": {
      "type": "string",
      "enum": [
        "pause",
        "resume",
        "archive"
      ]
    }
  }
} as const;
