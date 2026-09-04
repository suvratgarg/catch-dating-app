/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const submitParticipantOrganizerApplicationCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/submit_participant_organizer_application_payload.schema.json",
  "title": "SubmitParticipantOrganizerApplicationCallablePayload",
  "description": "Submits one participant-reviewed native application and an exact organizer field grant.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "formId",
    "formVersionId",
    "targetKind",
    "targetId",
    "submissionKey",
    "answers",
    "reviewedQuestionIds",
    "saveToIntakeCanonicalFieldIds",
    "consentVersion",
    "confirmedConsent"
  ],
  "properties": {
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
    "formVersionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "targetKind": {
      "type": "string",
      "enum": [
        "organizer",
        "event",
        "campaign"
      ]
    },
    "targetId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "submissionKey": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{8,120}$"
    },
    "answers": {
      "type": "array",
      "minItems": 1,
      "maxItems": 100,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "questionId",
          "value"
        ],
        "properties": {
          "questionId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
          },
          "value": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "valueKind",
              "textValue",
              "numberValue",
              "booleanValue",
              "dateValue",
              "optionValues",
              "assetIds"
            ],
            "properties": {
              "valueKind": {
                "type": "string",
                "enum": [
                  "empty",
                  "text",
                  "number",
                  "boolean",
                  "date",
                  "options",
                  "assets"
                ]
              },
              "textValue": {
                "type": [
                  "string",
                  "null"
                ],
                "maxLength": 4000
              },
              "numberValue": {
                "type": [
                  "number",
                  "null"
                ],
                "minimum": -1000000000,
                "maximum": 1000000000
              },
              "booleanValue": {
                "type": [
                  "boolean",
                  "null"
                ]
              },
              "dateValue": {
                "type": [
                  "string",
                  "null"
                ],
                "format": "date"
              },
              "optionValues": {
                "type": "array",
                "maxItems": 100,
                "items": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160
                }
              },
              "assetIds": {
                "type": "array",
                "maxItems": 10,
                "uniqueItems": true,
                "items": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                }
              }
            }
          }
        }
      }
    },
    "reviewedQuestionIds": {
      "type": "array",
      "minItems": 1,
      "maxItems": 100,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 120
      }
    },
    "saveToIntakeCanonicalFieldIds": {
      "type": "array",
      "maxItems": 40,
      "uniqueItems": true,
      "items": {
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
      }
    },
    "consentVersion": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80
    },
    "confirmedConsent": {
      "type": "boolean",
      "const": true
    }
  },
  "definitions": {
    "answerInput": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "questionId",
        "value"
      ],
      "properties": {
        "questionId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        "value": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "valueKind",
            "textValue",
            "numberValue",
            "booleanValue",
            "dateValue",
            "optionValues",
            "assetIds"
          ],
          "properties": {
            "valueKind": {
              "type": "string",
              "enum": [
                "empty",
                "text",
                "number",
                "boolean",
                "date",
                "options",
                "assets"
              ]
            },
            "textValue": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 4000
            },
            "numberValue": {
              "type": [
                "number",
                "null"
              ],
              "minimum": -1000000000,
              "maximum": 1000000000
            },
            "booleanValue": {
              "type": [
                "boolean",
                "null"
              ]
            },
            "dateValue": {
              "type": [
                "string",
                "null"
              ],
              "format": "date"
            },
            "optionValues": {
              "type": "array",
              "maxItems": 100,
              "items": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160
              }
            },
            "assetIds": {
              "type": "array",
              "maxItems": 10,
              "uniqueItems": true,
              "items": {
                "type": "string",
                "minLength": 1,
                "maxLength": 180
              }
            }
          }
        }
      }
    }
  }
} as const;
