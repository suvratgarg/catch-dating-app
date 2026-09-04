/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const publishOrganizerApplicationFormCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/publish_organizer_application_form_payload.schema.json",
  "title": "PublishOrganizerApplicationFormCallablePayload",
  "description": "Creates or revises and publishes one provider-neutral organizer application form.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "formId",
    "expectedRevision",
    "title",
    "description",
    "defaultTargetKind",
    "questions",
    "consentCopy",
    "consentVersion",
    "retentionCopy"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "formId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "expectedRevision": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "title": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160
    },
    "description": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 1000
    },
    "defaultTargetKind": {
      "type": "string",
      "enum": [
        "organizer",
        "event",
        "campaign"
      ]
    },
    "questions": {
      "type": "array",
      "minItems": 1,
      "maxItems": 100,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "questionId",
          "key",
          "label",
          "helpText",
          "kind",
          "required",
          "options",
          "canonicalFieldId",
          "privacyClass",
          "prefillPolicy",
          "hostPresentation"
        ],
        "properties": {
          "questionId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
          },
          "key": {
            "type": "string",
            "pattern": "^[A-Za-z][A-Za-z0-9_]{0,79}$"
          },
          "label": {
            "type": "string",
            "minLength": 1,
            "maxLength": 240
          },
          "helpText": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 500
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
              "file"
            ]
          },
          "required": {
            "type": "boolean"
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
                  "maxLength": 80
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
          "privacyClass": {
            "type": "string",
            "enum": [
              "contact",
              "profile",
              "sensitive",
              "organizerCustom"
            ]
          },
          "prefillPolicy": {
            "type": "string",
            "enum": [
              "never",
              "participantReviewRequired"
            ]
          },
          "hostPresentation": {
            "type": "string",
            "enum": [
              "detailOnly",
              "filterable",
              "sortable"
            ]
          }
        }
      }
    },
    "consentCopy": {
      "type": "string",
      "minLength": 1,
      "maxLength": 2000
    },
    "consentVersion": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80
    },
    "retentionCopy": {
      "type": "string",
      "minLength": 1,
      "maxLength": 1000
    }
  }
} as const;
