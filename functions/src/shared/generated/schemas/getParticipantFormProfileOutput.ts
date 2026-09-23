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
    "intakeRevision"
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
          "options"
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
    }
  }
} as const;
