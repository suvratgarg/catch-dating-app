/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const clubPostDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/club_posts.schema.json",
  "title": "ClubPostDocument",
  "description": "Legacy organizer-post projection stored at clubs/{clubId}/posts/{postId} during the clubs-to-organizers migration.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "club_posts",
  "x-firestore-path": "clubs/{clubId}/posts/{postId}",
  "x-document-id-field": "id",
  "x-owner": "createClubPost callable",
  "required": [
    "authorUid",
    "text",
    "audience",
    "createdAt",
    "status"
  ],
  "properties": {
    "authorUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "text": {
      "type": "string",
      "minLength": 1,
      "maxLength": 500,
      "x-catch-ownership": "callable-owned"
    },
    "photoPath": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 500,
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
    "audience": {
      "type": "string",
      "enum": [
        "followers"
      ],
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
    "status": {
      "type": "string",
      "enum": [
        "active",
        "removed"
      ],
      "x-catch-ownership": "callable-owned"
    }
  }
} as const;
