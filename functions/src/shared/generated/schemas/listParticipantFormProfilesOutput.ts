/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listParticipantFormProfilesCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/list_participant_form_profiles_response.schema.json",
  "title": "ListParticipantFormProfilesCallableResponse",
  "description": "Private summary metadata only; invalid or withdrawn response sources are omitted.",
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
          "responseId",
          "organizerId",
          "organizerName",
          "formTitle",
          "submittedAtMillis",
          "claimedAtMillis",
          "cardFieldCount"
        ],
        "properties": {
          "responseId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "organizerId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "organizerName": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 240
          },
          "formTitle": {
            "type": "string",
            "maxLength": 160
          },
          "submittedAtMillis": {
            "type": "integer",
            "minimum": 0,
            "maximum": 9007199254740991
          },
          "claimedAtMillis": {
            "anyOf": [
              {
                "type": "integer",
                "minimum": 0,
                "maximum": 9007199254740991
              },
              {
                "type": "null"
              }
            ]
          },
          "cardFieldCount": {
            "type": "integer",
            "minimum": 0,
            "maximum": 100
          }
        }
      }
    },
    "nextCursor": {
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
    }
  }
} as const;
