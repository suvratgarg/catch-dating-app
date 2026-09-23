/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const claimParticipantFormProfileCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/claim_participant_form_profile_payload.schema.json",
  "title": "ClaimParticipantFormProfileCallablePayload",
  "description": "Claim reviewed form data for the authenticated participant without enabling dating discovery or event admission.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "responseId",
    "expectedProfileRevision",
    "requestId",
    "termsVersion",
    "selectedQuestionIds",
    "profile",
    "expectedIntakeRevision"
  ],
  "properties": {
    "responseId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expectedProfileRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "requestId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{16,100}$"
    },
    "termsVersion": {
      "type": "string",
      "const": "form-profile-claim-v1"
    },
    "selectedQuestionIds": {
      "type": "array",
      "maxItems": 100,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      }
    },
    "profile": {
      "description": "Explicit participant-reviewed core values. Phone identity comes from verified Auth, never a form answer.",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "displayName",
        "dateOfBirth",
        "gender"
      ],
      "properties": {
        "name": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        "firstName": {
          "type": "string",
          "maxLength": 80
        },
        "lastName": {
          "type": "string",
          "maxLength": 80
        },
        "displayName": {
          "type": "string",
          "minLength": 1,
          "maxLength": 80,
          "pattern": ".*\\S.*"
        },
        "gender": {
          "type": "string",
          "enum": [
            "man",
            "woman",
            "nonBinary",
            "other"
          ]
        },
        "email": {
          "anyOf": [
            {
              "const": ""
            },
            {
              "type": "string",
              "format": "email",
              "maxLength": 320
            }
          ]
        },
        "instagramHandle": {
          "anyOf": [
            {
              "type": "string",
              "minLength": 1,
              "maxLength": 30,
              "pattern": "^[A-Za-z0-9._]{1,30}$"
            },
            {
              "type": "null"
            }
          ]
        },
        "city": {
          "anyOf": [
            {
              "type": "string",
              "minLength": 1,
              "maxLength": 120,
              "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
            },
            {
              "type": "null"
            }
          ]
        },
        "height": {
          "type": [
            "integer",
            "null"
          ],
          "minimum": 120,
          "maximum": 220
        },
        "occupation": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 120
        },
        "company": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 120
        },
        "education": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "highSchool",
            "someCollege",
            "bachelors",
            "masters",
            "phd",
            "tradeSchool",
            "other",
            null
          ]
        },
        "religion": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "hindu",
            "muslim",
            "christian",
            "sikh",
            "jain",
            "buddhist",
            "other",
            "nonReligious",
            null
          ]
        },
        "languages": {
          "type": "array",
          "maxItems": 20,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "enum": [
              "english",
              "hindi",
              "marathi",
              "tamil",
              "telugu",
              "kannada",
              "bengali",
              "gujarati",
              "punjabi",
              "malayalam",
              "odia",
              "other"
            ]
          }
        },
        "relationshipGoal": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "relationship",
            "casual",
            "marriage",
            "friendship",
            "unsure",
            null
          ]
        },
        "drinking": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "never",
            "socially",
            "often",
            null
          ]
        },
        "smoking": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "never",
            "occasionally",
            "often",
            null
          ]
        },
        "workout": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "never",
            "sometimes",
            "often",
            "everyday",
            null
          ]
        },
        "diet": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "omnivore",
            "vegetarian",
            "vegan",
            "jain",
            "other",
            null
          ]
        },
        "children": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "dontHave",
            "haveWantMore",
            "haveNoMore",
            "wantSomeday",
            "dontWant",
            null
          ]
        },
        "dateOfBirth": {
          "type": "string",
          "format": "date"
        },
        "interestedInGenders": {
          "type": "array",
          "minItems": 0,
          "maxItems": 8,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "enum": [
              "man",
              "woman",
              "nonBinary",
              "other"
            ]
          },
          "x-catch-ownership": "client-writable"
        }
      }
    },
    "expectedIntakeRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "reviewedLinkedinUrl": {
      "type": "string",
      "maxLength": 2048,
      "format": "uri",
      "pattern": "^https://([a-z]{2,3}\\.)?(www\\.)?linkedin\\.com/in/[^\\s]+$"
    }
  }
} as const;
