/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerContactIdentityLinkDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_contact_identity_links.schema.json",
  "title": "OrganizerContactIdentityLinkDocument",
  "description": "Server-only identity evidence edge used for keyed candidate lookup. Hashes are restricted identifiers, not anonymous data.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerContactIdentityLinks",
  "x-firestore-path": "organizerContactIdentityLinks/{identityLinkId}",
  "x-document-id-field": "identityLinkId",
  "x-owner": "organizer audience identity resolver",
  "required": [
    "organizerId",
    "contactId",
    "originContactId",
    "attendeeId",
    "kind",
    "identityHash",
    "hashVersion",
    "confidence",
    "source",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "contactId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "originContactId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "attendeeId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "description": "Legacy evidence-row key: an attendee id for roster sources or a deterministic form-response key for Host Forms."
    },
    "kind": {
      "type": "string",
      "enum": [
        "uid",
        "phone",
        "email",
        "provider"
      ]
    },
    "identityHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "hashVersion": {
      "type": "string",
      "enum": [
        "hmac-sha256-v1"
      ]
    },
    "confidence": {
      "type": "string",
      "enum": [
        "proposed",
        "verified"
      ]
    },
    "source": {
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
