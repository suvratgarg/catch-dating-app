/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerContactOriginDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_contact_origins.schema.json",
  "title": "OrganizerContactOriginDocument",
  "description": "Server-owned provenance for one organizer contact source. Source facts are immutable; only currentContactId moves during a receipt-backed merge or unmerge.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerContactOrigins",
  "x-firestore-path": "organizerContactOrigins/{originId}",
  "x-document-id-field": "originId",
  "x-owner": "approved organizer contact creators and organizer contact merge callables",
  "required": [
    "organizerId",
    "currentContactId",
    "originContactId",
    "sourceKind",
    "sourceEntityKind",
    "sourceEntityId",
    "eventId",
    "formId",
    "responseId",
    "actorClass",
    "actorUid",
    "observedAt",
    "originVersion",
    "createdAt"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "currentContactId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "originContactId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "sourceKind": {
      "type": "string",
      "enum": [
        "catchBooking",
        "hostImport",
        "hostManual",
        "webOtp",
        "providerSync",
        "hostForm"
      ]
    },
    "sourceEntityKind": {
      "type": "string",
      "enum": [
        "eventAttendee",
        "manualEntry",
        "hostFormResponse",
        "providerRecord",
        "importBatch",
        "webRegistration",
        "hostApplicationResponse"
      ]
    },
    "sourceEntityId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "eventId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    },
    "formId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    },
    "responseId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    },
    "actorClass": {
      "type": "string",
      "enum": [
        "participant",
        "organizerManager",
        "provider",
        "system"
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
    "observedAt": {
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
    "originVersion": {
      "type": "integer",
      "const": 1
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
    }
  }
} as const;
