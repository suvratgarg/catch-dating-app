/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerPostDeliveryOperationDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_post_delivery_operations.schema.json",
  "title": "OrganizerPostDeliveryOperationDocument",
  "description": "Server-owned retry state and aggregate delivery receipt for one organizer follower update.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerPostDeliveryOperations",
  "x-firestore-path": "organizerPostDeliveryOperations/{postId}",
  "x-document-id-field": "id",
  "x-owner": "createOrganizerPost callable and dispatchPendingOrganizerFollowerUpdates scheduler",
  "required": [
    "organizerId",
    "postId",
    "authorUid",
    "requestId",
    "payloadHash",
    "status",
    "remainingWeeklyQuota",
    "cursorFollowId",
    "recipientCount",
    "excludedCount",
    "activityAvailableCount",
    "pushAttemptedCount",
    "pushAcceptedCount",
    "pushFailedCount",
    "pushUnknownCount",
    "errorCodes",
    "attemptCount",
    "leaseOwner",
    "leaseExpiresAt",
    "createdAt",
    "updatedAt",
    "completedAt"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "postId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "authorUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "payloadHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$",
      "x-catch-ownership": "server-only"
    },
    "status": {
      "type": "string",
      "enum": [
        "pending",
        "processing",
        "completed",
        "partial"
      ],
      "x-catch-ownership": "server-only"
    },
    "remainingWeeklyQuota": {
      "type": "integer",
      "minimum": 0,
      "maximum": 3,
      "x-catch-ownership": "server-only"
    },
    "cursorFollowId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "recipientCount": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "server-only"
    },
    "excludedCount": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "server-only"
    },
    "activityAvailableCount": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "server-only"
    },
    "pushAttemptedCount": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "server-only"
    },
    "pushAcceptedCount": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "server-only"
    },
    "pushFailedCount": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "server-only"
    },
    "pushUnknownCount": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "server-only"
    },
    "errorCodes": {
      "type": "array",
      "maxItems": 20,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 120
      },
      "x-catch-ownership": "server-only"
    },
    "attemptCount": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "server-only"
    },
    "leaseOwner": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "leaseExpiresAt": {
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
      "x-catch-ownership": "server-only"
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
      "x-catch-ownership": "server-only"
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
      "x-catch-ownership": "server-only"
    },
    "completedAt": {
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
      "x-catch-ownership": "server-only"
    }
  }
} as const;
