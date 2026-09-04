/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerApplicationResponseDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_application_responses.schema.json",
  "title": "OrganizerApplicationResponseDocument",
  "description": "Immutable answer snapshot for one native, imported, or connector-originated organizer application response.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerApplicationResponses",
  "x-firestore-path": "organizerApplicationResponses/{responseId}",
  "x-document-id-field": "responseId",
  "x-owner": "organizer application submission and import callables",
  "required": [
    "organizerId",
    "applicationId",
    "formId",
    "formVersionId",
    "linkedUid",
    "answers",
    "source",
    "consentVersion",
    "grantId",
    "submittedAt"
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
    "linkedUid": {
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
    "answers": {
      "type": "array",
      "minItems": 1,
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
    "source": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "kind",
        "providerId",
        "externalFormId",
        "externalResponseId",
        "importReceiptId"
      ],
      "properties": {
        "kind": {
          "type": "string",
          "enum": [
            "native",
            "tabularImport",
            "connector"
          ]
        },
        "providerId": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 80
        },
        "externalFormId": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 240
        },
        "externalResponseId": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 240
        },
        "importReceiptId": {
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
        }
      }
    },
    "consentVersion": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 80
    },
    "grantId": {
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
    "submittedAt": {
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
  }
} as const;
