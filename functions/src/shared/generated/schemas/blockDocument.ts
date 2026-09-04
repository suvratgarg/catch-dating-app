/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const blockDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/blocks.schema.json",
  "title": "BlockDocument",
  "description": "Canonical safety block edge stored at blocks/{blockId}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "blocks",
  "x-firestore-path": "blocks/{blockId}",
  "x-document-id-field": "id",
  "x-owner": "safety callables and block trigger",
  "required": [
    "blockerUserId",
    "blockedUserId",
    "createdAt",
    "source"
  ],
  "properties": {
    "blockerUserId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "blockedUserId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
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
    "source": {
      "type": "string",
      "enum": [
        "profile",
        "chat",
        "match",
        "support"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "reasonCode": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80,
      "x-catch-ownership": "callable-owned"
    }
  }
} as const;
