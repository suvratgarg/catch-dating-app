/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerPostDeliveryRecipientDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_post_delivery_recipients.schema.json",
  "title": "OrganizerPostDeliveryRecipientDocument",
  "description": "Server-only post-scoped, de-identified per-recipient retry evidence for an organizer follower update.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerPostDeliveryRecipients",
  "x-firestore-path": "organizerPostDeliveryRecipients/{receiptId}",
  "x-document-id-field": "id",
  "x-owner": "createOrganizerPost callable and dispatchPendingOrganizerFollowerUpdates scheduler",
  "required": [
    "organizerId",
    "postId",
    "activityStatus",
    "pushStatus",
    "activityNotificationId",
    "excluded",
    "errorCode",
    "expiresAt",
    "createdAt",
    "updatedAt"
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
    "activityStatus": {
      "type": "string",
      "enum": [
        "created",
        "existing",
        "failed"
      ],
      "x-catch-ownership": "server-only"
    },
    "pushStatus": {
      "type": "string",
      "enum": [
        "ineligible",
        "accepted",
        "failed",
        "unknown"
      ],
      "x-catch-ownership": "server-only"
    },
    "activityNotificationId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "excluded": {
      "type": "boolean",
      "x-catch-ownership": "server-only"
    },
    "errorCode": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 120,
      "x-catch-ownership": "server-only"
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
      },
      "x-catch-ownership": "server-only",
      "x-firestore-ttl": true
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
    }
  }
} as const;
