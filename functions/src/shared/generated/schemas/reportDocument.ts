/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const reportDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/reports.schema.json",
  "title": "ReportDocument",
  "description": "Canonical safety report stored at reports/{reportId}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "reports",
  "x-firestore-path": "reports/{reportId}",
  "x-document-id-field": "id",
  "x-owner": "reportUser callable",
  "required": [
    "reporterUserId",
    "targetUserId",
    "createdAt",
    "source",
    "status"
  ],
  "properties": {
    "reporterUserId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "targetUserId": {
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
    "status": {
      "type": "string",
      "enum": [
        "open",
        "reviewed",
        "dismissed"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "reasonCode": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80,
      "x-catch-ownership": "callable-owned"
    },
    "contextId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "notes": {
      "type": "string",
      "maxLength": 1000,
      "x-catch-ownership": "callable-owned"
    }
  }
} as const;
