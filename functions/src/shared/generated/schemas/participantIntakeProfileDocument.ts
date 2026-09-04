/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const participantIntakeProfileDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/participant_intake_profiles.schema.json",
  "title": "ParticipantIntakeProfileDocument",
  "description": "Participant-private reusable application values. This is neither a Catch dating profile nor organizer-visible CRM data.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "participantIntakeProfiles",
  "x-firestore-path": "participantIntakeProfiles/{uid}",
  "x-document-id-field": "uid",
  "x-owner": "participant intake profile callables",
  "required": [
    "fields",
    "revision",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "fields": {
      "type": "array",
      "maxItems": 40,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "canonicalFieldId",
          "value",
          "sourceApplicationId",
          "reviewedByParticipantAt",
          "updatedAt"
        ],
        "properties": {
          "canonicalFieldId": {
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
          },
          "sourceApplicationId": {
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
          "reviewedByParticipantAt": {
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
        }
      }
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
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
  }
} as const;
