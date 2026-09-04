/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerFormResponseDraftDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_form_response_drafts.schema.json",
  "title": "OrganizerFormResponseDraftDocument",
  "description": "Expiring version-bound respondent autosave state.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "formId",
    "versionId",
    "publicFormId",
    "status",
    "revision",
    "identityKind",
    "respondentUid",
    "draftTokenHash",
    "answers",
    "consentAccepted",
    "consentVersion",
    "sourceLinkId",
    "createdAt",
    "updatedAt",
    "expiresAt",
    "submittedResponseId"
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
    "status": {
      "type": "string",
      "enum": [
        "active",
        "submitted",
        "expired",
        "withdrawn"
      ]
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
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
    "draftTokenHash": {
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
    "consentAccepted": {
      "type": "boolean"
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
    },
    "expiresAt": {
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
    "submittedResponseId": {
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
  },
  "x-firestore-collection": "organizerFormResponseDrafts",
  "x-firestore-path": "organizerFormResponseDrafts/{draftId}",
  "x-document-id-field": "draftId",
  "x-owner": "organizer form respondent callables"
} as const;
