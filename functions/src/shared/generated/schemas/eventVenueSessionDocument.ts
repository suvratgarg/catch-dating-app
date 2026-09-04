/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventVenueSessionDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_venue_sessions.schema.json",
  "title": "EventVenueSessionDocument",
  "description": "Short-lived server-owned venue-presence authority shown only in the Host live QR.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventVenueSessions",
  "x-firestore-path": "eventVenueSessions/{sessionId}",
  "x-document-id-field": "sessionId",
  "x-owner": "createEventVenueSession callable; no client reads or writes",
  "required": [
    "eventId",
    "organizerId",
    "createdBy",
    "issuedAt",
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
    "createdBy": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "issuedAt": {
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
