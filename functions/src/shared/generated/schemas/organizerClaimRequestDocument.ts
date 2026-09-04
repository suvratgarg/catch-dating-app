/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerClaimRequestDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_claim_requests.schema.json",
  "title": "OrganizerClaimRequestDocument",
  "description": "Server-owned organizer listing claim request stored at organizerClaimRequests/{requestId}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerClaimRequests",
  "x-firestore-path": "organizerClaimRequests/{requestId}",
  "x-document-id-field": "requestId",
  "x-owner": "requestOrganizerClaim and adminDecideOrganizerClaim callables",
  "required": [
    "requestId",
    "organizerId",
    "requesterUid",
    "requesterName",
    "requesterRole",
    "businessEmail",
    "businessPhone",
    "proofUrls",
    "message",
    "status",
    "createdAt",
    "updatedAt",
    "decidedAt",
    "decidedByUid",
    "decisionReason",
    "previousRequestId"
  ],
  "properties": {
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "requesterUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "requesterName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "x-catch-ownership": "callable-owned"
    },
    "requesterRole": {
      "type": "string",
      "enum": [
        "owner",
        "founder",
        "manager",
        "marketer",
        "venueManager",
        "other"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "businessEmail": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 320,
      "x-catch-ownership": "callable-owned"
    },
    "businessPhone": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 32,
      "x-catch-ownership": "callable-owned"
    },
    "proofUrls": {
      "type": "array",
      "maxItems": 8,
      "items": {
        "type": "string",
        "format": "uri",
        "maxLength": 2048
      },
      "uniqueItems": true,
      "x-catch-ownership": "callable-owned"
    },
    "message": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 1000,
      "x-catch-ownership": "callable-owned"
    },
    "status": {
      "type": "string",
      "enum": [
        "pending",
        "approved",
        "rejected",
        "withdrawn",
        "superseded"
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
    },
    "decidedAt": {
      "anyOf": [
        {
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
        {
          "type": "null"
        }
      ],
      "x-catch-ownership": "callable-owned"
    },
    "decidedByUid": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ],
      "x-catch-ownership": "callable-owned"
    },
    "decisionReason": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 1000,
      "x-catch-ownership": "callable-owned"
    },
    "previousRequestId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ],
      "x-catch-ownership": "callable-owned"
    }
  }
} as const;
