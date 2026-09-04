/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventShareIntentDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_share_intents.schema.json",
  "title": "EventShareIntentDocument",
  "description": "Evidence that a signed-in actor opened a Catch-owned share surface; it is not proof that a message was sent.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventShareIntents",
  "x-firestore-path": "eventShareIntents/{intentId}",
  "x-document-id-field": "intentId",
  "x-owner": "event share intent callable",
  "required": [
    "eventId",
    "organizerId",
    "inviteLinkId",
    "actorUid",
    "actorKind",
    "surface",
    "creativeId",
    "channelHint",
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
    "actorUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "actorKind": {
      "type": "string",
      "enum": [
        "host",
        "attendee",
        "member"
      ]
    },
    "surface": {
      "type": "string",
      "enum": [
        "hostApp",
        "consumerApp",
        "runtimeWeb"
      ]
    },
    "creativeId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "channelHint": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        "systemShare",
        "copyLink",
        "whatsapp",
        "sms",
        "email",
        null
      ]
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
