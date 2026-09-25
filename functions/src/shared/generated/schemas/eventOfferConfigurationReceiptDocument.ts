/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventOfferConfigurationReceiptDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_offer_configuration_receipts.schema.json",
  "title": "EventOfferConfigurationReceiptDocument",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "actorUid",
    "organizerId",
    "requestId",
    "requestHash",
    "appliedPreferencesRevision",
    "createdAt",
    "eventId"
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
    "appliedPreferencesRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000000000
    },
    "eventId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$"
    }
  },
  "x-firestore-collection": "eventOfferConfigurationReceipts",
  "x-firestore-path": "eventOfferConfigurationReceipts/{receiptId}",
  "x-document-id-field": "receiptId",
  "x-owner": "event offer manager operations"
} as const;
