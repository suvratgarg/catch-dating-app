/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programLodgingReceiptDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/program_lodging_receipts.schema.json",
  "title": "ProgramLodgingReceiptDocument",
  "description": "Immutable private operation receipt bound to program, actor and exact request. Replay rechecks current authority and returns current workflow; it never restores a prior approval.",
  "x-firestore-collection": "programLodgingReceipts",
  "x-firestore-path": "programLodgingReceipts/{receiptId}",
  "x-document-id-field": "receiptId",
  "x-owner": "private program lodging server operations",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "programId",
    "organizerId",
    "receipt"
  ],
  "properties": {
    "programId": {
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
    "receipt": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "operationId",
        "requestHash",
        "actorUid",
        "resultingRevision"
      ],
      "properties": {
        "operationId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{1,100}$"
        },
        "requestHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "actorUid": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "x-catch-ownership": "server-only"
        },
        "resultingRevision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991,
          "x-catch-ownership": "server-only"
        }
      },
      "x-catch-ownership": "server-only"
    }
  }
} as const;
