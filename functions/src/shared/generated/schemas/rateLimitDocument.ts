/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const rateLimitDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/rate_limits.schema.json",
  "title": "RateLimitDocument",
  "description": "Server-owned callable rate-limit counter stored at rateLimits/{docId}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "rateLimits",
  "x-firestore-path": "rateLimits/{docId}",
  "x-document-id-field": "docId",
  "x-owner": "shared callable rate-limit middleware",
  "required": [
    "uid",
    "action",
    "windowKey",
    "count",
    "expiresAt"
  ],
  "properties": {
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "action": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "x-catch-ownership": "server-only"
    },
    "windowKey": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "server-only"
    },
    "count": {
      "type": "integer",
      "minimum": 1,
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
      "x-catch-ownership": "server-only"
    }
  }
} as const;
