/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerEventVenueDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_event_venues.schema.json",
  "title": "OrganizerEventVenueDocument",
  "description": "Reusable organizer-owned event venue stored at organizerEventVenues/{organizerId_venueId}. Events copy the meeting location and capacity so later venue edits never rewrite event history.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerEventVenues",
  "x-firestore-path": "organizerEventVenues/{venueDocumentId}",
  "x-document-id-field": "id",
  "x-owner": "organizer manager through upsertOrganizerEventVenue",
  "required": [
    "organizerId",
    "venueId",
    "label",
    "meetingLocation",
    "status",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "venueId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$",
      "x-catch-ownership": "callable-owned"
    },
    "label": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "x-catch-ownership": "callable-owned"
    },
    "meetingLocation": {
      "type": "object",
      "additionalProperties": false,
      "description": "Canonical meeting location selected from Google Places or a manually pinned map coordinate.",
      "required": [
        "name",
        "latitude",
        "longitude"
      ],
      "properties": {
        "name": {
          "type": "string",
          "minLength": 1,
          "maxLength": 240
        },
        "address": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 500
        },
        "placeId": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 256
        },
        "latitude": {
          "type": "number",
          "minimum": -90,
          "maximum": 90
        },
        "longitude": {
          "type": "number",
          "minimum": -180,
          "maximum": 180
        },
        "notes": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 1000
        }
      },
      "x-catch-ownership": "callable-owned"
    },
    "defaultEventCapacity": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 1,
      "maximum": 1000,
      "x-catch-ownership": "callable-owned"
    },
    "status": {
      "type": "string",
      "enum": [
        "active",
        "archived"
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
      },
      "x-catch-ownership": "callable-owned"
    }
  }
} as const;
