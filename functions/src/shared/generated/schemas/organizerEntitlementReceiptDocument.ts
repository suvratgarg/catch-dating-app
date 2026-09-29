/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerEntitlementReceiptDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_entitlement_receipts.schema.json",
  "title": "OrganizerEntitlementReceiptDocument",
  "description": "Idempotency receipt at organizerEntitlementReceipts/{receiptId} for admin entitlement mutations. receiptId is organizerId_operationId; a matching contentHash replays the stored result, a different hash fails closed.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerEntitlementReceipts",
  "x-firestore-path": "organizerEntitlementReceipts/{receiptId}",
  "x-document-id-field": "receiptId",
  "x-owner": "organizer entitlement admin callables",
  "required": [
    "schemaVersion",
    "receiptId",
    "operationId",
    "organizerId",
    "actorUid",
    "action",
    "contentHash",
    "resultRevision",
    "grantId",
    "createdAt",
    "expiresAt"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1,
      "x-catch-ownership": "server-only"
    },
    "receiptId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "operationId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "actorUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "action": {
      "type": "string",
      "enum": [
        "grant",
        "revoke"
      ],
      "x-catch-ownership": "server-only"
    },
    "contentHash": {
      "type": "string",
      "minLength": 16,
      "maxLength": 128,
      "x-catch-ownership": "server-only"
    },
    "resultRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991,
      "x-catch-ownership": "server-only"
    },
    "grantId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
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
    "expiresAt": {
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
      "x-firestore-ttl": true,
      "x-catch-ownership": "server-only"
    }
  }
} as const;
