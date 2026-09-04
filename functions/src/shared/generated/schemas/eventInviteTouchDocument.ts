/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventInviteTouchDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_invite_touches.schema.json",
  "title": "EventInviteTouchDocument",
  "description": "Short-lived privacy-minimized evidence that an invitation URL was resolved.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventInviteTouches",
  "x-firestore-path": "eventInviteTouches/{touchId}",
  "x-document-id-field": "touchId",
  "x-owner": "event invite resolution callable",
  "required": [
    "eventId",
    "organizerId",
    "inviteLinkId",
    "touchKind",
    "surface",
    "actorUid",
    "sessionHash",
    "likelyHuman",
    "botReason",
    "attributionEligible",
    "createdAt",
    "expiresAt"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "inviteLinkId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "touchKind": {
      "type": "string",
      "enum": [
        "open",
        "redirect"
      ]
    },
    "surface": {
      "type": "string",
      "enum": [
        "consumerApp",
        "hostApp",
        "runtimeWeb",
        "marketingWeb",
        "unknown"
      ]
    },
    "actorUid": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "sessionHash": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 64,
      "maxLength": 64,
      "pattern": "^[a-f0-9]{64}$"
    },
    "likelyHuman": {
      "type": "boolean"
    },
    "botReason": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        "previewCrawler",
        "knownBot",
        "missingClientSignal",
        null
      ]
    },
    "attributionEligible": {
      "type": "boolean"
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
      }
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
      }
    }
  }
} as const;
