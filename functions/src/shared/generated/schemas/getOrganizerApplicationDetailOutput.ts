/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getOrganizerApplicationDetailCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/get_organizer_application_detail_response.schema.json",
  "title": "GetOrganizerApplicationDetailCallableResponse",
  "description": "Manager-only application answers, source context, and validated outreach actions.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "applicationId",
    "formId",
    "formVersionId",
    "targetKind",
    "targetId",
    "applicantDisplayName",
    "reviewStatus",
    "dataAccessState",
    "answers",
    "outreach",
    "reviewNote",
    "assignedReviewerUid",
    "submittedAtMillis",
    "reviewedAtMillis",
    "revision"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "applicationId": {
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
    "applicantDisplayName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160
    },
    "reviewStatus": {
      "type": "string",
      "enum": [
        "submitted",
        "inReview",
        "approved",
        "waitlisted",
        "declined",
        "withdrawn"
      ]
    },
    "dataAccessState": {
      "type": "string",
      "enum": [
        "organizerImported",
        "activeParticipantGrant",
        "revokedParticipantGrant",
        "submittedFormResponse"
      ]
    },
    "answers": {
      "type": "array",
      "maxItems": 100,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "questionId",
          "questionKey",
          "questionLabel",
          "questionKind",
          "canonicalFieldId",
          "privacyClass",
          "hostPresentation",
          "value"
        ],
        "properties": {
          "questionId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
          },
          "questionKey": {
            "type": "string",
            "pattern": "^[A-Za-z][A-Za-z0-9_]{0,79}$"
          },
          "questionLabel": {
            "type": "string",
            "minLength": 1,
            "maxLength": 240
          },
          "questionKind": {
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
          "hostPresentation": {
            "type": "string",
            "enum": [
              "detailOnly",
              "filterable",
              "sortable"
            ]
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
    "outreach": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "phoneE164",
        "email",
        "instagramUrl",
        "linkedinUrl"
      ],
      "properties": {
        "phoneE164": {
          "type": [
            "string",
            "null"
          ],
          "pattern": "^\\+[1-9][0-9]{7,14}$"
        },
        "email": {
          "type": [
            "string",
            "null"
          ],
          "format": "email",
          "maxLength": 320
        },
        "instagramUrl": {
          "type": [
            "string",
            "null"
          ],
          "format": "uri",
          "maxLength": 500
        },
        "linkedinUrl": {
          "type": [
            "string",
            "null"
          ],
          "format": "uri",
          "maxLength": 500
        }
      }
    },
    "reviewNote": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 2000
    },
    "assignedReviewerUid": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "submittedAtMillis": {
      "type": "integer",
      "minimum": 0
    },
    "reviewedAtMillis": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 0
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "contactId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "sourceResponseId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    }
  },
  "definitions": {
    "outreach": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "phoneE164",
        "email",
        "instagramUrl",
        "linkedinUrl"
      ],
      "properties": {
        "phoneE164": {
          "type": [
            "string",
            "null"
          ],
          "pattern": "^\\+[1-9][0-9]{7,14}$"
        },
        "email": {
          "type": [
            "string",
            "null"
          ],
          "format": "email",
          "maxLength": 320
        },
        "instagramUrl": {
          "type": [
            "string",
            "null"
          ],
          "format": "uri",
          "maxLength": 500
        },
        "linkedinUrl": {
          "type": [
            "string",
            "null"
          ],
          "format": "uri",
          "maxLength": 500
        }
      }
    }
  }
} as const;
