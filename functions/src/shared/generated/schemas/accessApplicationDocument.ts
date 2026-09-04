/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const accessApplicationDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/access_applications.schema.json",
  "title": "AccessApplicationDocument",
  "description": "Owner-submitted launch access application stored at accessApplications/{uid}; review and cohort fields are admin-owned.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "accessApplications",
  "x-firestore-path": "accessApplications/{uid}",
  "x-owner": "authenticated applicant owns application fields while editable; admin callables own review, cohort, and activation fields",
  "required": [
    "applicationVersion",
    "status",
    "city",
    "role",
    "eventTypes",
    "availabilityWindows",
    "wantsToHost",
    "submissionCount",
    "createdAt",
    "submittedAt",
    "updatedAt"
  ],
  "properties": {
    "applicationVersion": {
      "type": "integer",
      "minimum": 1,
      "x-catch-ownership": "client-writable"
    },
    "status": {
      "type": "string",
      "enum": [
        "pending",
        "waitlisted",
        "invited",
        "approvedForProfile",
        "activeMember",
        "paused",
        "notSelectedYet"
      ],
      "x-catch-ownership": "admin-callable-owned"
    },
    "city": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$",
      "x-catch-ownership": "client-writable"
    },
    "role": {
      "type": "string",
      "enum": [
        "member",
        "host",
        "both"
      ],
      "x-catch-ownership": "client-writable"
    },
    "eventTypes": {
      "type": "array",
      "items": {
        "type": "string",
        "enum": [
          "runClub",
          "walkingSocial",
          "coffee",
          "boardGames",
          "fitnessClass",
          "food",
          "culture"
        ]
      },
      "minItems": 1,
      "maxItems": 7,
      "uniqueItems": true,
      "x-catch-ownership": "client-writable"
    },
    "availabilityWindows": {
      "type": "array",
      "items": {
        "type": "string",
        "enum": [
          "weekdayMornings",
          "weekdayEvenings",
          "saturdayMornings",
          "saturdayEvenings",
          "sundayMornings",
          "sundayEvenings"
        ]
      },
      "minItems": 1,
      "maxItems": 6,
      "uniqueItems": true,
      "x-catch-ownership": "client-writable"
    },
    "wantsToHost": {
      "type": "boolean",
      "x-catch-ownership": "client-writable"
    },
    "inviteCode": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 64,
      "pattern": "^[A-Za-z0-9_-]*$",
      "x-catch-ownership": "client-writable"
    },
    "instagramHandle": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 30,
      "pattern": "^[A-Za-z0-9._]{0,30}$",
      "x-catch-ownership": "client-writable"
    },
    "referralSource": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 240,
      "x-catch-ownership": "client-writable"
    },
    "whyCatch": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 12,
      "maxLength": 1000,
      "x-catch-ownership": "client-writable"
    },
    "cohortId": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 120,
      "x-catch-ownership": "admin-callable-owned"
    },
    "hostUserId": {
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
      "x-catch-ownership": "admin-callable-owned"
    },
    "reviewerUid": {
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
      "x-catch-ownership": "admin-callable-owned"
    },
    "reviewNote": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 1000,
      "x-catch-ownership": "admin-callable-owned"
    },
    "submissionCount": {
      "type": "integer",
      "minimum": 1,
      "x-catch-ownership": "client-writable"
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
      "x-catch-ownership": "client-server-timestamp"
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
      },
      "x-catch-ownership": "client-server-timestamp"
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
      "x-catch-ownership": "client-server-timestamp"
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
      ],
      "x-catch-ownership": "admin-callable-owned"
    }
  }
} as const;
