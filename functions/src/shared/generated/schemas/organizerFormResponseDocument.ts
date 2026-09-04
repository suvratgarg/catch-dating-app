/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerFormResponseDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_form_responses.schema.json",
  "title": "OrganizerFormResponseDocument",
  "description": "Immutable submitted response envelope with withdrawal state.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "formId",
    "versionId",
    "publicFormId",
    "draftId",
    "status",
    "identityKind",
    "respondentUid",
    "identity",
    "withdrawalTokenHash",
    "answers",
    "answerSnapshots",
    "consentVersion",
    "sourceLinkId",
    "completionMillis",
    "submittedAt",
    "withdrawnAt"
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
    "versionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "publicFormId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{20,80}$"
    },
    "draftId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "status": {
      "type": "string",
      "enum": [
        "submitted",
        "withdrawn"
      ]
    },
    "identityKind": {
      "type": "string",
      "enum": [
        "anonymous",
        "emailVerified",
        "phoneVerified",
        "catchAccount"
      ]
    },
    "respondentUid": {
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
    "identity": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "displayName",
        "email",
        "phoneE164",
        "searchName",
        "origin"
      ],
      "properties": {
        "displayName": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 160
        },
        "email": {
          "type": [
            "string",
            "null"
          ],
          "format": "email",
          "maxLength": 320
        },
        "phoneE164": {
          "type": [
            "string",
            "null"
          ],
          "pattern": "^\\+[1-9][0-9]{7,14}$"
        },
        "searchName": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 160
        },
        "origin": {
          "type": "string",
          "enum": [
            "anonymous",
            "respondentGranted",
            "organizerAcquired"
          ]
        }
      }
    },
    "withdrawalTokenHash": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^[a-f0-9]{64}$"
    },
    "answers": {
      "type": "object",
      "maxProperties": 4000,
      "propertyNames": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      },
      "additionalProperties": {
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
      }
    },
    "answerSnapshots": {
      "type": "array",
      "maxItems": 4000,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "questionId",
          "key",
          "label",
          "kind",
          "answer"
        ],
        "properties": {
          "questionId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "key": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "label": {
            "type": "string",
            "minLength": 1,
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
          "answer": {
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
          }
        }
      }
    },
    "consentVersion": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80
    },
    "sourceLinkId": {
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
    "completionMillis": {
      "type": "integer",
      "minimum": 0,
      "maximum": 604800000
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
    },
    "withdrawnAt": {
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
  },
  "x-firestore-collection": "organizerFormResponses",
  "x-firestore-path": "organizerFormResponses/{responseId}",
  "x-document-id-field": "responseId",
  "x-owner": "organizer form submission callable"
} as const;
