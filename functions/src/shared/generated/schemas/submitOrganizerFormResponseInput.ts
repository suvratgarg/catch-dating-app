/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const submitOrganizerFormResponseCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/submit_organizer_form_response_payload.schema.json",
  "title": "SubmitOrganizerFormResponseCallablePayload",
  "description": "Idempotently submits one completed version-bound draft.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "draftId",
    "draftToken",
    "expectedRevision",
    "requestId"
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
    "expectedRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "requestId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{16,120}$"
    }
  }
} as const;
