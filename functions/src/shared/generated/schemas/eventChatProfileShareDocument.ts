/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventChatProfileShareDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_chat_profile_shares.schema.json",
  "title": "EventChatProfileShareDocument",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "uid",
    "organizerId",
    "revision",
    "selection",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "organizerId": {
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
    "revision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "selection": {
      "anyOf": [
        {
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
            "termsVersion": {
              "type": "string",
              "const": "event-profile-sharing-v1"
            }
          }
        },
        {
          "type": "null"
        }
      ]
    },
    "createdAt": {
      "type": "object",
      "description": "Serialized Firestore Timestamp fixture shape.",
      "x-firestore-type": "timestamp",
      "additionalProperties": false,
      "required": [
        "_seconds",
        "_nanoseconds"
      ],
      "properties": {
        "_seconds": {
          "type": "integer"
        },
        "_nanoseconds": {
          "type": "integer",
          "minimum": 0,
          "maximum": 999999999
        }
      }
    },
    "updatedAt": {
      "type": "object",
      "description": "Serialized Firestore Timestamp fixture shape.",
      "x-firestore-type": "timestamp",
      "additionalProperties": false,
      "required": [
        "_seconds",
        "_nanoseconds"
      ],
      "properties": {
        "_seconds": {
          "type": "integer"
        },
        "_nanoseconds": {
          "type": "integer",
          "minimum": 0,
          "maximum": 999999999
        }
      }
    }
  },
  "description": "Explicit event-specific mini-profile selection. Pointers only; current membership, profile and card revisions must still match.",
  "x-firestore-collection": "eventChatProfileShares",
  "x-firestore-path": "eventChatProfileShares/{shareId}",
  "x-document-id-field": "shareId",
  "x-owner": "event profile sharing callables"
} as const;
