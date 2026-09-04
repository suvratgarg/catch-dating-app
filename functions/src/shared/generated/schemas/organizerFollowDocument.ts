/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerFollowDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_follows.schema.json",
  "title": "OrganizerFollowDocument",
  "description": "Canonical consumer follow edge stored at organizerFollows/{organizerId_uid}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerFollows",
  "x-firestore-path": "organizerFollows/{followId}",
  "x-document-id-field": "id",
  "x-owner": "organizer follow callables; parent followerCount is trigger-owned",
  "required": [
    "organizerId",
    "uid",
    "status",
    "pushNotificationsEnabled",
    "followedAt",
    "unfollowedAt"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "status": {
      "type": "string",
      "enum": [
        "active",
        "inactive"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "pushNotificationsEnabled": {
      "type": "boolean",
      "x-catch-ownership": "callable-owned"
    },
    "followedAt": {
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
    "unfollowedAt": {
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
    }
  }
} as const;
