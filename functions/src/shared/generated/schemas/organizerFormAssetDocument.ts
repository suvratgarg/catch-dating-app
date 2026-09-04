/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerFormAssetDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_form_assets.schema.json",
  "title": "OrganizerFormAssetDocument",
  "description": "Version- and draft-scoped metadata for private respondent uploads; bytes remain in protected Storage.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerFormAssets",
  "x-firestore-path": "organizerFormAssets/{assetId}",
  "x-document-id-field": "assetId",
  "x-owner": "organizer form respondent asset callables",
  "x-ttl-field": "expiresAt",
  "required": [
    "organizerId",
    "formId",
    "versionId",
    "draftId",
    "questionId",
    "respondentUid",
    "uploadTokenHash",
    "storagePath",
    "originalFileName",
    "contentType",
    "declaredSizeBytes",
    "declaredSha256",
    "sizeBytes",
    "status",
    "createdAt",
    "expiresAt",
    "finalizedAt",
    "deletedAt"
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
    "draftId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "questionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
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
    "uploadTokenHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "storagePath": {
      "type": "string",
      "pattern": "^organizerForms/[^/]+/[^/]+/[^/]+$",
      "maxLength": 600
    },
    "originalFileName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 255
    },
    "contentType": {
      "type": "string",
      "enum": [
        "image/jpeg",
        "image/png",
        "image/webp",
        "application/pdf"
      ]
    },
    "declaredSizeBytes": {
      "type": "integer",
      "minimum": 1,
      "maximum": 26214400
    },
    "declaredSha256": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "sizeBytes": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 1,
      "maximum": 26214400
    },
    "status": {
      "type": "string",
      "enum": [
        "uploading",
        "ready",
        "rejected",
        "deleted"
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
    "finalizedAt": {
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
    },
    "deletedAt": {
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
