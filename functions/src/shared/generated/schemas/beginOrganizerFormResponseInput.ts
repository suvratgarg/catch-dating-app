/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const beginOrganizerFormResponseCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/begin_organizer_form_response_payload.schema.json",
  "title": "BeginOrganizerFormResponseCallablePayload",
  "description": "Starts or idempotently resumes a version-bound response draft.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "publicFormId",
    "sourceToken",
    "requestId"
  ],
  "properties": {
    "publicFormId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{20,80}$"
    },
    "sourceToken": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^[A-Za-z0-9_-]{20,160}$"
    },
    "requestId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{16,120}$"
    }
  }
} as const;
