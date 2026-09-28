/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const assistantClientsDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/assistant_clients.schema.json",
  "title": "AssistantClientDocument",
  "description": "Private binding of a non-admin Firebase Auth client account.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "classification",
    "clientId",
    "authUid",
    "active",
    "revision",
    "createdAt",
    "updatedAt",
    "updatedByUid"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "classification": {
      "const": "sales_private"
    },
    "clientId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "authUid": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "active": {
      "type": "boolean"
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000000000
    },
    "createdAt": {
      "type": "string",
      "format": "date-time"
    },
    "updatedAt": {
      "type": "string",
      "format": "date-time"
    },
    "updatedByUid": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    }
  },
  "x-firestore-collection": "assistantClients",
  "x-firestore-path": "assistantClients/{clientId}",
  "x-document-id-field": "clientId",
  "x-owner": "sales assistant gateway server-only management"
} as const;
