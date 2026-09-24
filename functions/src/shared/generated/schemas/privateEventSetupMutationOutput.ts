/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const privateEventSetupMutationCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/private_event_setup_mutation_response.schema.json",
  "title": "PrivateEventSetupMutationCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "setupRevision",
    "replayed"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "setupRevision": {
      "type": "integer",
      "minimum": 1
    },
    "replayed": {
      "type": "boolean"
    }
  }
} as const;
