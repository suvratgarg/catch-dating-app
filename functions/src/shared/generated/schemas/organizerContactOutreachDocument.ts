/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerContactOutreachDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_contact_outreach.schema.json",
  "title": "OrganizerContactOutreachDocument",
  "description": "Manager-asserted outreach attempt on one organizer contact. Records are append-only through the manager-authorized record callable, appear on the contact timeline, and are excluded from contact exports.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerContactOutreach",
  "x-firestore-path": "organizerContactOutreach/{outreachId}",
  "x-document-id-field": "outreachId",
  "x-owner": "manager-only organizer contact outreach callable",
  "required": [
    "organizerId",
    "contactId",
    "authorUid",
    "channel",
    "outcome",
    "occurredAt",
    "revision",
    "createdAt",
    "updatedAt",
    "updatedByUid"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "contactId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "authorUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "channel": {
      "type": "string",
      "enum": [
        "phoneCall",
        "whatsapp",
        "email",
        "sms",
        "inPerson",
        "other"
      ],
      "x-catch-ownership": "server-only"
    },
    "outcome": {
      "type": "string",
      "enum": [
        "reached",
        "noAnswer",
        "leftMessage",
        "wrongContact",
        "attempted"
      ],
      "x-catch-ownership": "server-only"
    },
    "note": {
      "type": "string",
      "minLength": 1,
      "maxLength": 500,
      "x-catch-ownership": "server-only"
    },
    "occurredAt": {
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
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991,
      "x-catch-ownership": "server-only"
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
      "x-catch-ownership": "server-only"
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
      "x-catch-ownership": "server-only"
    },
    "updatedByUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    }
  }
} as const;
