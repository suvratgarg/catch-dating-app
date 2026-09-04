/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const crossPathsSuggestionExposureDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/cross_paths_suggestion_exposures.schema.json",
  "title": "CrossPathsSuggestionExposureDocument",
  "description": "Server-only, session-idempotent Cross Paths exposure receipt used for ranking fatigue. It contains no private preference values or roster projection.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "crossPathsSuggestionExposures",
  "x-firestore-path": "crossPathsSuggestionExposures/{exposureId}",
  "x-document-id-field": "id",
  "x-owner": "getCrossPathsSuggestions callable",
  "required": [
    "viewerUid",
    "candidateUid",
    "eventId",
    "sessionIdHash",
    "rankingVersion",
    "shownAt",
    "expiresAt"
  ],
  "properties": {
    "viewerUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "candidateUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "sessionIdHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$",
      "x-catch-ownership": "server-only"
    },
    "rankingVersion": {
      "type": "integer",
      "minimum": 1,
      "x-catch-ownership": "server-only"
    },
    "shownAt": {
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
