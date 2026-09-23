/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const promoteFormCommunicationIntentCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/promote_form_communication_intent_response.schema.json",
  "title": "PromoteFormCommunicationIntentCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "responseId",
    "promotedPurposes",
    "replayed"
  ],
  "properties": {
    "responseId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "promotedPurposes": {
      "type": "array",
      "uniqueItems": true,
      "items": {
        "type": "string",
        "enum": [
          "organizer:eventOperations",
          "organizer:marketing",
          "catch:marketing"
        ]
      }
    },
    "replayed": {
      "type": "boolean"
    }
  }
} as const;
