/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const setEventAssignmentFeatureConsentCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/set_event_assignment_feature_consent_payload.schema.json",
  "title": "SetEventAssignmentFeatureConsentCallablePayload",
  "description": "Verified participant grants or withdraws assignment-only use of one exact submitted answer.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "featureId",
    "responseId",
    "decision",
    "expectedRevision",
    "requestId"
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
    "responseId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "decision": {
      "enum": [
        "grant",
        "withdraw"
      ]
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
