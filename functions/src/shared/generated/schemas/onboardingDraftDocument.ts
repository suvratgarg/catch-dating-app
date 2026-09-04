/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const onboardingDraftDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/onboarding_drafts.schema.json",
  "title": "OnboardingDraftDocument",
  "description": "Owner-private, intentionally extensible onboarding draft stored at onboarding_drafts/{uid}.",
  "type": "object",
  "additionalProperties": true,
  "x-firestore-collection": "onboarding_drafts",
  "x-firestore-path": "onboarding_drafts/{uid}",
  "x-document-id-field": "uid",
  "x-owner": "authenticated draft owner",
  "required": [
    "step"
  ],
  "properties": {
    "step": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "client-writable"
    },
    "draftVersion": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "client-writable"
    },
    "firstName": {
      "type": "string",
      "maxLength": 80,
      "x-catch-ownership": "client-writable"
    },
    "lastName": {
      "type": "string",
      "maxLength": 80,
      "x-catch-ownership": "client-writable"
    },
    "dateOfBirth": {
      "anyOf": [
        {
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
        {
          "type": "null"
        }
      ],
      "x-catch-ownership": "client-writable"
    },
    "phoneNumber": {
      "type": "string",
      "maxLength": 32,
      "x-catch-ownership": "client-writable"
    },
    "countryCode": {
      "type": "string",
      "maxLength": 8,
      "x-catch-ownership": "client-writable"
    },
    "gender": {
      "anyOf": [
        {
          "type": "string",
          "enum": [
            "man",
            "woman",
            "nonBinary",
            "other"
          ]
        },
        {
          "type": "null"
        }
      ],
      "x-catch-ownership": "client-writable"
    },
    "interestedInGenders": {
      "type": "array",
      "items": {
        "type": "string",
        "enum": [
          "man",
          "woman",
          "nonBinary",
          "other"
        ]
      },
      "uniqueItems": true,
      "x-catch-ownership": "client-writable"
    },
    "instagramHandle": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 80,
      "x-catch-ownership": "client-writable"
    },
    "profilePrompts": {
      "type": "array",
      "items": {
        "title": "ProfilePromptAnswer",
        "description": "One structured written profile prompt answer stored on users and publicProfiles.",
        "type": "object",
        "additionalProperties": false,
        "required": [
          "promptId",
          "prompt",
          "answer"
        ],
        "properties": {
          "promptId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "prompt": {
            "type": "string",
            "minLength": 1,
            "maxLength": 140
          },
          "answer": {
            "type": "string",
            "maxLength": 300
          }
        },
        "x-catch-catalog": "../catalogs/profile_prompts.json"
      },
      "maxItems": 3,
      "x-catch-ownership": "client-writable"
    }
  }
} as const;
