/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerFormDomainDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_form_domains.schema.json",
  "title": "OrganizerFormDomainDocument",
  "description": "Server-owned exact hostname lease and verified form binding. Client reads and writes are forbidden.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerFormDomains",
  "x-firestore-path": "organizerFormDomains/{hostname}",
  "x-document-id-field": "hostname",
  "x-owner": "organizer form domain registry",
  "required": [
    "hostname",
    "organizerId",
    "formId",
    "publicFormId",
    "ownershipChallenge",
    "expectedCname",
    "status",
    "certificateStatus",
    "verifiedAtMillis",
    "generation",
    "reservedAtMillis",
    "pendingExpiresAtMillis"
  ],
  "properties": {
    "hostname": {
      "type": "string",
      "minLength": 4,
      "maxLength": 253,
      "pattern": "^[a-z0-9.-]+$"
    },
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
    "ownershipChallenge": {
      "type": "string",
      "pattern": "^catch-verification=[A-Za-z0-9_-]{32}$"
    },
    "expectedCname": {
      "type": "string",
      "minLength": 4,
      "maxLength": 253
    },
    "status": {
      "enum": [
        "pending",
        "verified",
        "active",
        "revoked"
      ]
    },
    "certificateStatus": {
      "enum": [
        "pending",
        "ready",
        "failed"
      ]
    },
    "verifiedAtMillis": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 0
    },
    "generation": {
      "type": "integer",
      "minimum": 1
    },
    "reservedAtMillis": {
      "type": "integer",
      "minimum": 0
    },
    "pendingExpiresAtMillis": {
      "type": "integer",
      "minimum": 1
    }
  }
} as const;
