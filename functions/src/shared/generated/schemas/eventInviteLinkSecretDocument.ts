/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventInviteLinkSecretDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_invite_link_secrets.schema.json",
  "title": "EventInviteLinkSecretDocument",
  "description": "Server-only bearer token material for one event invitation link.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventInviteLinkSecrets",
  "x-firestore-path": "eventInviteLinkSecrets/{inviteLinkId}",
  "x-document-id-field": "inviteLinkId",
  "x-owner": "event invite link callables",
  "required": [
    "eventId",
    "organizerId",
    "token",
    "tokenHash",
    "tokenVersion",
    "createdAt",
    "updatedAt"
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
    "token": {
      "type": "string",
      "minLength": 32,
      "maxLength": 128,
      "pattern": "^[A-Za-z0-9_-]+$"
    },
    "tokenHash": {
      "type": "string",
      "minLength": 64,
      "maxLength": 64,
      "pattern": "^[a-f0-9]{64}$"
    },
    "tokenVersion": {
      "type": "integer",
      "minimum": 1,
      "maximum": 10
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
      }
    }
  }
} as const;
