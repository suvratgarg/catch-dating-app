/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getEventChatProfileSharingCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/get_event_chat_profile_sharing_payload.schema.json",
  "title": "GetEventChatProfileSharingCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "expectedUid"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expectedUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "previewSelection": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "profileRevision",
        "membershipRevision",
        "coreFieldIds",
        "photoId",
        "card",
        "termsVersion"
      ],
      "properties": {
        "profileRevision": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "membershipRevision": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "coreFieldIds": {
          "type": "array",
          "maxItems": 14,
          "uniqueItems": true,
          "items": {
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
          }
        },
        "photoId": {
          "anyOf": [
            {
              "type": "string",
              "minLength": 1,
              "maxLength": 80,
              "pattern": "^[A-Za-z0-9_-]+$"
            },
            {
              "type": "null"
            }
          ]
        },
        "card": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "responseId",
                "revision",
                "questionIds"
              ],
              "properties": {
                "responseId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                },
                "revision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "questionIds": {
                  "type": "array",
                  "uniqueItems": true,
                  "maxItems": 20,
                  "items": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180
                  },
                  "minItems": 1
                }
              }
            },
            {
              "type": "null"
            }
          ]
        },
        "firstName": {
          "type": "string",
          "minLength": 1,
          "maxLength": 80,
          "pattern": "^\\S(?:[\\s\\S]*\\S)?$"
        },
        "introduction": {
          "type": "string",
          "minLength": 1,
          "maxLength": 500,
          "pattern": "^\\S(?:[\\s\\S]*\\S)?$"
        },
        "termsVersion": {
          "type": "string",
          "enum": [
            "event-profile-sharing-v1",
            "event-profile-sharing-v2"
          ]
        }
      },
      "description": "Owner-only proposed selection; no sharing receipt is written."
    }
  }
} as const;
