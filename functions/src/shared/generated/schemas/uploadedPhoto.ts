/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const uploadedPhotoSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/embedded/uploaded_photo.schema.json",
  "title": "UploadedPhoto",
  "description": "Canonical uploaded image object for ordered media galleries, logos, and event photos.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "id",
    "url",
    "storagePath",
    "thumbnailUrl",
    "thumbnailStoragePath",
    "position",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "id": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "pattern": "^[A-Za-z0-9_-]+$"
    },
    "url": {
      "type": "string",
      "format": "uri",
      "maxLength": 2048
    },
    "storagePath": {
      "type": "string",
      "minLength": 1,
      "maxLength": 512,
      "pattern": "^[^/\\u0000][^\\u0000]*$"
    },
    "thumbnailUrl": {
      "anyOf": [
        {
          "type": "string",
          "format": "uri",
          "maxLength": 2048
        },
        {
          "type": "null"
        }
      ]
    },
    "thumbnailStoragePath": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 512,
          "pattern": "^[^/\\u0000][^\\u0000]*$"
        },
        {
          "type": "null"
        }
      ]
    },
    "position": {
      "type": "integer",
      "minimum": 0
    },
    "moderation": {
      "type": [
        "object",
        "null"
      ],
      "additionalProperties": false,
      "required": [
        "status"
      ],
      "properties": {
        "status": {
          "type": "string",
          "enum": [
            "pending",
            "approved",
            "rejected"
          ]
        },
        "reason": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 240
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
  },
  "definitions": {
    "storageObjectPath": {
      "type": "string",
      "minLength": 1,
      "maxLength": 512,
      "pattern": "^[^/\\u0000][^\\u0000]*$"
    }
  }
} as const;
