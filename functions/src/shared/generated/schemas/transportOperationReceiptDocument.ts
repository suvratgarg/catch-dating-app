/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const transportOperationReceiptDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/transport_operation_receipts.schema.json",
  "title": "TransportOperationReceiptDocument",
  "description": "Server-owned idempotency receipt for offline-replayed transport mutations. An exact retry returns the original result; a conflicting reuse of the client operation id fails closed.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "transportOperationReceipts",
  "x-firestore-path": "transportOperationReceipts/{receiptId}",
  "x-document-id-field": "receiptId",
  "x-owner": "program transport mutation callables",
  "required": [
    "programId",
    "operationKind",
    "clientOperationId",
    "actorUid",
    "requestHash",
    "tripId",
    "legId",
    "resultRevision",
    "createdAt",
    "expiresAt",
    "resultJson"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "operationKind": {
      "type": "string",
      "enum": [
        "markReady",
        "claim",
        "unclaim",
        "markDisrupted",
        "dispatch",
        "markArrived",
        "voidTrip",
        "manifestImport"
      ]
    },
    "clientOperationId": {
      "type": "string",
      "minLength": 8,
      "maxLength": 120
    },
    "actorUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "requestHash": {
      "type": "string",
      "minLength": 32,
      "maxLength": 128,
      "description": "Stable hash of the mutation payload; a same-id different-payload replay is rejected."
    },
    "tripId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "legId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "resultRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991,
      "description": "Committed entity revision returned to a replayed caller."
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
    "expiresAt": {
      "type": "object",
      "description": "Receipt retention horizon for cleanup sweeps.",
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
    "resultJson": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 20000,
      "description": "Serialized operation response for exact replay of compound results (e.g. manifest import summaries). Null for scalar-result operations."
    }
  }
} as const;
