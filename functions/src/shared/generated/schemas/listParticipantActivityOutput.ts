/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listParticipantActivityCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/list_participant_activity_response.schema.json",
  "title": "ListParticipantActivityCallableResponse",
  "description": "Metadata only after exact account, response and immutable-version proof.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "items",
    "nextCursor"
  ],
  "properties": {
    "items": {
      "type": "array",
      "maxItems": 30,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "sourceKind",
          "sourceId",
          "organizerId",
          "eventId",
          "formId",
          "versionId",
          "formTitle",
          "purpose",
          "submittedAtMillis"
        ],
        "properties": {
          "sourceKind": {
            "type": "string",
            "const": "formResponse"
          },
          "sourceId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "organizerId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "formId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "versionId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "eventId": {
            "anyOf": [
              {
                "type": "string",
                "minLength": 1,
                "maxLength": 180
              },
              {
                "type": "null"
              }
            ]
          },
          "formTitle": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160
          },
          "purpose": {
            "type": "string",
            "enum": [
              "application",
              "registration",
              "intake",
              "waiver",
              "feedback",
              "survey"
            ]
          },
          "submittedAtMillis": {
            "type": "integer",
            "minimum": 0,
            "maximum": 9007199254740991
          }
        }
      }
    },
    "nextCursor": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 8192
    }
  }
} as const;
