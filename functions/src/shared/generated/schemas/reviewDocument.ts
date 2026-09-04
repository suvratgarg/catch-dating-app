/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const reviewDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/reviews.schema.json",
  "title": "ReviewDocument",
  "description": "Canonical organizer review stored at reviews/{reviewId}. Verified reviews come from attended Catch events; unverified reviews can come from public listing pages.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "reviews",
  "x-firestore-path": "reviews/{reviewId}",
  "x-document-id-field": "id",
  "x-owner": "review mutation callables; aggregate stats are trigger-owned",
  "x-internal-demo-fields": [
    "synthetic",
    "seedPrefix",
    "scenario",
    "demoOps",
    "demoOpsId",
    "demoOpsCommand"
  ],
  "required": [
    "organizerId",
    "reviewerUserId",
    "reviewerName",
    "rating",
    "comment",
    "createdAt"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "eventId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "reviewerUserId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ],
      "description": "Catch user id for signed-in reviewers. Null for anonymous public listing reviews.",
      "x-catch-ownership": "callable-owned"
    },
    "reviewerName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "x-catch-ownership": "callable-owned"
    },
    "rating": {
      "type": "integer",
      "minimum": 1,
      "maximum": 5,
      "x-catch-ownership": "callable-owned"
    },
    "comment": {
      "type": "string",
      "maxLength": 1000,
      "x-catch-ownership": "callable-owned"
    },
    "verificationStatus": {
      "type": "string",
      "enum": [
        "verified",
        "unverified"
      ],
      "description": "Verified reviews are created only after attended Catch events; public listing reviews are unverified.",
      "x-catch-ownership": "callable-owned"
    },
    "source": {
      "type": "string",
      "enum": [
        "catchEvent",
        "publicListing"
      ],
      "description": "Submission surface that created the review.",
      "x-catch-ownership": "callable-owned"
    },
    "moderationStatus": {
      "type": "string",
      "enum": [
        "published",
        "pending",
        "rejected"
      ],
      "description": "Public rendering status for organizer listing pages.",
      "x-catch-ownership": "callable-owned"
    },
    "isAnonymous": {
      "type": "boolean",
      "description": "True when the public display name should be the anonymous fallback rather than a user-supplied or profile name.",
      "x-catch-ownership": "callable-owned"
    },
    "submittedFromPath": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 240,
      "description": "Website path that submitted an unverified public listing review.",
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
    },
    "updatedAt": {
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
      ],
      "x-catch-ownership": "callable-owned"
    },
    "ownerResponse": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "hostUserId",
        "hostName",
        "hostAvatarUrl",
        "message",
        "createdAt",
        "updatedAt"
      ],
      "properties": {
        "hostUserId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "x-catch-ownership": "callable-owned"
        },
        "hostName": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120,
          "x-catch-ownership": "callable-owned"
        },
        "hostAvatarUrl": {
          "type": [
            "string",
            "null"
          ],
          "format": "uri",
          "x-catch-ownership": "callable-owned"
        },
        "message": {
          "type": "string",
          "minLength": 1,
          "maxLength": 1000,
          "x-catch-ownership": "callable-owned"
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
          },
          "x-catch-ownership": "callable-owned"
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
          },
          "x-catch-ownership": "callable-owned"
        }
      }
    },
    "synthetic": {
      "type": "boolean",
      "description": "Internal demo seed marker used for cleanup and diagnostics."
    },
    "seedPrefix": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "description": "Internal demo seed prefix used for cleanup and diagnostics."
    },
    "scenario": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "description": "Internal demo seed scenario name used for cleanup and diagnostics."
    },
    "demoOps": {
      "type": "boolean",
      "description": "Internal demo-operations marker used for cleanup and diagnostics."
    },
    "demoOpsId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "description": "Internal demo-operations id used for cleanup and diagnostics."
    },
    "demoOpsCommand": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80,
      "description": "Internal demo-operations command name used for cleanup and diagnostics."
    }
  }
} as const;
