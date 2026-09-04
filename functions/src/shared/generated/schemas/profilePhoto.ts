/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const profilePhotoSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/embedded/profile_photo.schema.json",
  "title": "ProfilePhoto",
  "description": "Future canonical profile-photo object that groups display URLs, Firebase Storage object paths, prompt metadata, moderation state, order, and lifecycle timestamps.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "id",
    "url",
    "thumbnailUrl",
    "storagePath",
    "thumbnailStoragePath",
    "position",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "id": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80,
      "pattern": "^[A-Za-z0-9_-]+$"
    },
    "url": {
      "type": "string",
      "format": "uri",
      "maxLength": 2048
    },
    "thumbnailUrl": {
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
    "thumbnailStoragePath": {
      "type": "string",
      "minLength": 1,
      "maxLength": 512,
      "pattern": "^[^/\\u0000][^\\u0000]*$"
    },
    "prompt": {
      "anyOf": [
        {
          "title": "PhotoPromptAnswer",
          "description": "One optional display prompt selected for a profile photo slot. The caption field is legacy-only and should no longer be written by clients.",
          "type": "object",
          "additionalProperties": false,
          "required": [
            "photoIndex",
            "promptId",
            "prompt"
          ],
          "properties": {
            "photoIndex": {
              "type": "integer",
              "minimum": 0,
              "maximum": 5
            },
            "promptId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 80
            },
            "prompt": {
              "type": "string",
              "minLength": 1,
              "maxLength": 140
            },
            "caption": {
              "type": "string",
              "maxLength": 140,
              "deprecated": true,
              "description": "Legacy user-entered caption retained for compatibility with older documents."
            }
          },
          "x-catch-catalog": "../catalogs/photo_prompts.json"
        },
        {
          "type": "null"
        }
      ]
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
    "position": {
      "type": "integer",
      "minimum": 0,
      "maximum": 11
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
  },
  "x-storage-metadata": true,
  "x-future-field": "profilePhotos",
  "x-migration-contract": "../migrations/profile_photos_storage.json"
} as const;
