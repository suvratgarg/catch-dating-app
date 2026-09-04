/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerFormShareLinkDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_form_share_links.schema.json",
  "title": "OrganizerFormShareLinkDocument",
  "description": "Organizer-owned source-attributed stable public form link.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "formId",
    "publicFormId",
    "label",
    "source",
    "tokenHash",
    "createdByUid",
    "createdAt",
    "openCount",
    "startCount",
    "submissionCount"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "formId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "publicFormId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{20,80}$"
    },
    "label": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "source": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 120
    },
    "tokenHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "createdByUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
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
    "openCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 1000000000
    },
    "startCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 1000000000
    },
    "submissionCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 1000000000
    }
  },
  "x-firestore-collection": "organizerFormShareLinks",
  "x-firestore-path": "organizerFormShareLinks/{linkId}",
  "x-document-id-field": "linkId",
  "x-owner": "organizer form distribution callables"
} as const;
