/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerEventSetupDefaultReceiptDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_event_setup_default_receipts.schema.json",
  "title": "OrganizerEventSetupDefaultReceiptDocument",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "actorUid",
    "organizerId",
    "requestId",
    "requestHash",
    "appliedRevision",
    "createdAt"
  ],
  "properties": {
    "actorUid": {
      "type": "string",
      "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$"
    },
    "organizerId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$"
    },
    "requestId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{7,127}$"
    },
    "requestHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "appliedRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000000000
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
    }
  },
  "x-firestore-collection": "organizerEventSetupDefaultReceipts",
  "x-firestore-path": "organizerEventSetupDefaultReceipts/{receiptId}",
  "x-document-id-field": "receiptId",
  "x-owner": "organizer event setup manager operations"
} as const;
