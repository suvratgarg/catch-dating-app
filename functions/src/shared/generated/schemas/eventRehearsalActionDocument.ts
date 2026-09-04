/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventRehearsalActionDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_rehearsal_actions.schema.json",
  "title": "EventRehearsalActionDocument",
  "description": "Bounded idempotency and reproduction record for rehearsal actions.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventRehearsalActions",
  "x-firestore-path": "eventRehearsalActions/{actionDocumentId}",
  "x-document-id-field": "id",
  "x-owner": "event rehearsal callables",
  "required": [
    "sessionId",
    "clientActionId",
    "actorUid",
    "actorId",
    "kind",
    "name",
    "runtimeRevision",
    "virtualNow",
    "createdAt"
  ],
  "properties": {
    "sessionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "clientActionId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{8,120}$",
      "x-catch-ownership": "callable-owned"
    },
    "actorUid": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "actorId": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "kind": {
      "type": "string",
      "enum": [
        "control",
        "behavior",
        "spatial",
        "guest",
        "setup",
        "system"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "name": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80,
      "x-catch-ownership": "callable-owned"
    },
    "runtimeRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 2147483647,
      "x-catch-ownership": "callable-owned"
    },
    "virtualNow": {
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
    }
  }
} as const;
