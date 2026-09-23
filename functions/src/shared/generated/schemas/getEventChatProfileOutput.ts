/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getEventChatProfileCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/get_event_chat_profile_response.schema.json",
  "title": "GetEventChatProfileCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "participantUid",
    "displayName",
    "coreFields",
    "cardFields",
    "photo"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "participantUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "displayName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "coreFields": {
      "type": "array",
      "maxItems": 14,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "fieldId",
          "value"
        ],
        "properties": {
          "fieldId": {
            "type": "string",
            "enum": [
              "age",
              "gender",
              "city",
              "heightCm",
              "occupation",
              "company",
              "education",
              "languages",
              "relationshipGoal",
              "drinking",
              "smoking",
              "workout",
              "diet",
              "children"
            ]
          },
          "value": {
            "anyOf": [
              {
                "type": "string",
                "maxLength": 10000
              },
              {
                "type": "number"
              },
              {
                "type": "boolean"
              },
              {
                "type": "array",
                "maxItems": 100,
                "items": {
                  "type": "string",
                  "maxLength": 10000
                }
              }
            ]
          }
        }
      }
    },
    "cardFields": {
      "type": "array",
      "maxItems": 20,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "label",
          "value"
        ],
        "properties": {
          "label": {
            "type": "string",
            "maxLength": 240
          },
          "value": {
            "anyOf": [
              {
                "type": "string",
                "maxLength": 10000
              },
              {
                "type": "number"
              },
              {
                "type": "boolean"
              },
              {
                "type": "array",
                "maxItems": 100,
                "items": {
                  "type": "string",
                  "maxLength": 10000
                }
              }
            ]
          }
        }
      }
    },
    "photo": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "title": "GetParticipantFormPhotoCallableResponse",
          "description": "Bounded metadata-free JPEG bytes for private in-memory review; never an original upload URL.",
          "required": [
            "contentType",
            "previewBase64",
            "width",
            "height"
          ],
          "properties": {
            "contentType": {
              "type": "string",
              "const": "image/jpeg"
            },
            "previewBase64": {
              "type": "string",
              "minLength": 4,
              "maxLength": 349528,
              "pattern": "^[A-Za-z0-9+/]+={0,2}$"
            },
            "width": {
              "type": "integer",
              "minimum": 1,
              "maximum": 640
            },
            "height": {
              "type": "integer",
              "minimum": 1,
              "maximum": 640
            }
          }
        },
        {
          "type": "null"
        }
      ]
    }
  }
} as const;
