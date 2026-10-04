/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesDemoContinuationDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/sales_demo_continuations.schema.json",
  "title": "SalesDemoContinuationDocument",
  "description": "Bounded own completed-demo proof for private claim review delay. Contains references and hashes, never grant tokens or synthetic guest data. Every resume rechecks current identity, scope and real manager authority before Forms materialization.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "classification",
    "continuationId",
    "actorUid",
    "organizerId",
    "invitationId",
    "invitationRevision",
    "invitationExpiresAt",
    "blueprintId",
    "blueprintRevision",
    "sessionId",
    "sessionRevision",
    "setupHash",
    "completedAt",
    "createdAt",
    "expiresAt"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "classification": {
      "const": "sales_private"
    },
    "continuationId": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "actorUid": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "organizerId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "invitationId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "invitationRevision": {
      "type": "integer",
      "minimum": 1
    },
    "invitationExpiresAt": {
      "type": "string",
      "format": "date-time"
    },
    "blueprintId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "blueprintRevision": {
      "type": "integer",
      "minimum": 1
    },
    "sessionId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "sessionRevision": {
      "type": "integer",
      "minimum": 1
    },
    "setupHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "completedAt": {
      "type": "string",
      "format": "date-time"
    },
    "createdAt": {
      "type": "string",
      "format": "date-time"
    },
    "expiresAt": {
      "type": "string",
      "format": "date-time"
    }
  },
  "x-firestore-collection": "salesDemoContinuations",
  "x-firestore-path": "salesDemoContinuations/{continuationId}",
  "x-document-id-field": "continuationId",
  "x-owner": "private Sales Demo continuation boundary"
} as const;
