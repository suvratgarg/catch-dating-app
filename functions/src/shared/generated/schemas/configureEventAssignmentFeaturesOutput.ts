/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const configureEventAssignmentFeaturesCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/configure_event_assignment_features_response.schema.json",
  "title": "ConfigureEventAssignmentFeaturesCallableResponse",
  "description": "Saved soft-feature configuration revision, never a participant authorization.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "revision",
    "replayed"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "replayed": {
      "type": "boolean"
    }
  }
} as const;
