/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const setEventAssignmentFeatureConsentCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/set_event_assignment_feature_consent_response.schema.json",
  "title": "SetEventAssignmentFeatureConsentCallableResponse",
  "description": "Current exact-purpose participant decision, including replay status.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "featureId",
    "status",
    "revision",
    "receiptId",
    "replayed"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "featureId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "status": {
      "enum": [
        "granted",
        "withdrawn"
      ]
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "receiptId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "replayed": {
      "type": "boolean"
    }
  }
} as const;
