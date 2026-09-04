/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerApplicationAssetDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_application_assets.schema.json",
  "title": "OrganizerApplicationAssetDocument",
  "description": "Metadata for a private file uploaded with an organizer application; bytes remain in protected Storage.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerApplicationAssets",
  "x-firestore-path": "organizerApplicationAssets/{assetId}",
  "x-document-id-field": "assetId",
  "x-owner": "organizer application asset upload and moderation callables",
  "required": [
    "organizerId",
    "applicationId",
    "responseId",
    "questionId",
    "uploadedByUid",
    "storagePath",
    "originalFileName",
    "contentType",
    "sizeBytes",
    "sha256",
    "status",
    "createdAt",
    "deletedAt"
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
    "responseId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "questionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "uploadedByUid": {
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
    "storagePath": {
      "type": "string",
      "pattern": "^organizerApplications/[^/]+/[^/]+/[^/]+$",
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
    "sizeBytes": {
      "type": "integer",
      "minimum": 1,
      "maximum": 10485760
    },
    "sha256": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "status": {
      "type": "string",
      "enum": [
        "pendingScan",
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
