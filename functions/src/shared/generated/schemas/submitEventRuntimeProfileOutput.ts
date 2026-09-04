/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const submitEventRuntimeProfileCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/submit_event_runtime_profile_response.schema.json",
  "title": "SubmitEventRuntimeProfileCallableResponse",
  "description": "Server-recomputed Event Success runtime profile readiness.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "status",
    "requiredFieldIds",
    "completedFieldIds"
  ],
  "properties": {
    "status": {
      "type": "string",
      "enum": [
        "needsInput",
        "ready"
      ]
    },
    "requiredFieldIds": {
      "type": "array",
      "items": {
        "type": "string"
      },
      "maxItems": 10
    },
    "completedFieldIds": {
      "type": "array",
      "items": {
        "type": "string"
      },
      "maxItems": 10
    }
  }
} as const;
