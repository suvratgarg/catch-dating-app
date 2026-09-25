/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listEventAssignmentFeatureChoicesCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/list_event_assignment_feature_choices_response.schema.json",
  "title": "ListEventAssignmentFeatureChoicesCallableResponse",
  "description": "Only the authenticated respondent's reviewed answer labels and purpose-specific decisions; old grants remain withdrawable after mapping/source changes.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "choices"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "choices": {
      "type": "array",
      "maxItems": 1000,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "featureId",
          "responseId",
          "questionLabel",
          "answerLabel",
          "status",
          "revision",
          "canGrant"
        ],
        "properties": {
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
          "questionLabel": {
            "type": [
              "string",
              "null"
            ],
            "minLength": 1,
            "maxLength": 240
          },
          "answerLabel": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 500
          },
          "status": {
            "enum": [
              "notGranted",
              "granted",
              "withdrawn"
            ]
          },
          "revision": {
            "type": "integer",
            "minimum": 0,
            "maximum": 9007199254740991
          },
          "canGrant": {
            "type": "boolean"
          }
        }
      }
    }
  }
} as const;
