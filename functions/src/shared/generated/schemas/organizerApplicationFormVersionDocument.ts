/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerApplicationFormVersionDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_application_form_versions.schema.json",
  "title": "OrganizerApplicationFormVersionDocument",
  "description": "Immutable published or imported snapshot of one organizer application form.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerApplicationFormVersions",
  "x-firestore-path": "organizerApplicationFormVersions/{versionId}",
  "x-document-id-field": "versionId",
  "x-owner": "organizer application form publish and import callables",
  "required": [
    "organizerId",
    "formId",
    "version",
    "state",
    "title",
    "description",
    "questions",
    "consentCopy",
    "consentVersion",
    "retentionCopy",
    "createdByUid",
    "createdAt",
    "publishedAt"
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
    "version": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000000
    },
    "state": {
      "type": "string",
      "enum": [
        "draftSnapshot",
        "published",
        "retired"
      ]
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
    },
    "createdByUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
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
    "publishedAt": {
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
      ]
    }
  }
} as const;
