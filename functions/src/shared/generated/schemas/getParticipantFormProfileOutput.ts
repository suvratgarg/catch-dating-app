/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getParticipantFormProfileCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/get_participant_form_profile_response.schema.json",
  "title": "GetParticipantFormProfileCallableResponse",
  "description": "Participant-only form review, with an optimistic profile revision and no unrelated CRM data.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "responseId",
    "organizerId",
    "formId",
    "formTitle",
    "submittedAtMillis",
    "fields",
    "profileRevision",
    "termsVersion",
    "intakeRevision",
    "organizerName",
    "selectedCardQuestionIds",
    "claimedAtMillis",
    "currentProfile",
    "currentLinkedinUrl",
    "cardRevision"
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
    "formId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
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
    "fields": {
      "type": "array",
      "maxItems": 100,
      "items": {
        "description": "Only explicitly designated applicant-submitted answers.",
        "type": "object",
        "additionalProperties": false,
        "required": [
          "questionId",
          "destination",
          "canonicalFieldId",
          "label",
          "kind",
          "value",
          "options",
          "eventProfileEligible"
        ],
        "properties": {
          "questionId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "destination": {
            "type": "string",
            "enum": [
              "catchProfile",
              "organizerCard"
            ]
          },
          "canonicalFieldId": {
            "anyOf": [
              {
                "type": "string",
                "x-catch-catalog": "../catalogs/person_fields.json",
                "enum": [
                  "givenName",
                  "familyName",
                  "displayName",
                  "dateOfBirth",
                  "age",
                  "gender",
                  "phoneNumber",
                  "email",
                  "instagramHandle",
                  "linkedinUrl",
                  "profilePhoto",
                  "city",
                  "heightCm",
                  "occupation",
                  "company",
                  "education",
                  "languages",
                  "relationshipGoal",
                  "interestedInGenders",
                  "drinking",
                  "smoking",
                  "religion",
                  "workout",
                  "diet",
                  "children"
                ]
              },
              {
                "type": "null"
              }
            ]
          },
          "label": {
            "type": "string",
            "maxLength": 240
          },
          "kind": {
            "type": "string",
            "enum": [
              "shortText",
              "longText",
              "singleChoice",
              "multiChoice",
              "date",
              "phone",
              "email",
              "url",
              "number",
              "boolean",
              "file",
              "acknowledgement",
              "signature"
            ]
          },
          "value": {
            "anyOf": [
              {
                "type": "string",
                "maxLength": 10000
              },
              {
                "type": "number",
                "minimum": -1000000000,
                "maximum": 1000000000
              },
              {
                "type": "boolean"
              },
              {
                "type": "null"
              },
              {
                "type": "array",
                "maxItems": 100,
                "uniqueItems": true,
                "items": {
                  "type": "string",
                  "maxLength": 500
                }
              }
            ]
          },
          "options": {
            "type": "array",
            "maxItems": 100,
            "items": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "optionId",
                "label",
                "value"
              ],
              "properties": {
                "optionId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                },
                "label": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160
                },
                "value": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160
                }
              }
            }
          },
          "eventProfileEligible": {
            "type": "boolean",
            "description": "True only for a published field explicitly proposed for optional event-member sharing; the owner must still grant event-specific consent."
          }
        }
      }
    },
    "profileRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "termsVersion": {
      "type": "string",
      "const": "form-profile-claim-v1"
    },
    "intakeRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "organizerName": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 240
    },
    "selectedCardQuestionIds": {
      "type": "array",
      "maxItems": 100,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      }
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
    "currentProfile": {
      "anyOf": [
        {
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
        {
          "type": "null"
        }
      ]
    },
    "currentLinkedinUrl": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 2048
    },
    "cardRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    }
  }
} as const;
