/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerApplicationDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_applications.schema.json",
  "title": "OrganizerApplicationDocument",
  "description": "Organizer-scoped application review summary with no provider-specific answer shape.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerApplications",
  "x-firestore-path": "organizerApplications/{applicationId}",
  "x-document-id-field": "applicationId",
  "x-owner": "organizer application submission, import, and review callables",
  "required": [
    "organizerId",
    "formId",
    "formVersionId",
    "targetKind",
    "targetId",
    "linkedUid",
    "contactId",
    "applicantDisplayName",
    "applicantDisplayNameNormalized",
    "reviewStatus",
    "latestResponseId",
    "source",
    "assignedReviewerUid",
    "reviewNote",
    "revision",
    "submittedAt",
    "updatedAt",
    "reviewedAt"
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
    "contactId": {
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
    "applicantDisplayName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160
    },
    "applicantDisplayNameNormalized": {
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
    "latestResponseId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
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
    "assignedReviewerUid": {
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
    "reviewNote": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 2000
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
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
    "reviewedAt": {
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
