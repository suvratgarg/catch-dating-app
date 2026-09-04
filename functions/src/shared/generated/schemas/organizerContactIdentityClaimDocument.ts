/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerContactIdentityClaimDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_contact_identity_claims.schema.json",
  "title": "OrganizerContactIdentityClaimDocument",
  "description": "Singleton organizer-scoped ownership claim for a person-verified UID or phone identity.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerContactIdentityClaims",
  "x-firestore-path": "organizerContactIdentityClaims/{identityClaimId}",
  "x-document-id-field": "identityClaimId",
  "x-owner": "organizer audience identity resolver and merge operations",
  "required": [
    "organizerId",
    "kind",
    "identityHash",
    "hashVersion",
    "verifiedContactId",
    "originVerifiedContactId",
    "state",
    "conflictingContactIds",
    "revision",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "kind": {
      "type": "string",
      "enum": [
        "uid",
        "phone"
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
    "verifiedContactId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "originVerifiedContactId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "state": {
      "type": "string",
      "enum": [
        "verified",
        "conflicted"
      ]
    },
    "conflictingContactIds": {
      "type": "array",
      "maxItems": 20,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      }
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
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
