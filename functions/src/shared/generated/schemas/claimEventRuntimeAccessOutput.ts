/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const claimEventRuntimeAccessCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/claim_event_runtime_access_response.schema.json",
  "title": "ClaimEventRuntimeAccessCallableResponse",
  "description": "Result of claiming or requesting approval for Event Success runtime access.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "status",
    "attendeeId",
    "requiredFieldIds",
    "completedFieldIds"
  ],
  "properties": {
    "status": {
      "type": "string",
      "enum": [
        "pendingApproval",
        "needsInput",
        "ready"
      ]
    },
    "attendeeId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
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
