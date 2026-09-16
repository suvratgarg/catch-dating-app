/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventRuntimeDataRequestReceiptDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_runtime_data_request_receipts.schema.json",
  "title": "EventRuntimeDataRequestReceiptDocument",
  "description": "Immutable idempotency receipt for one required-data command.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventRuntimeDataRequestReceipts",
  "x-firestore-path": "eventRuntimeDataRequestReceipts/{receiptId}",
  "x-document-id-field": "receiptId",
  "x-owner": "server-only Event Runtime required-data coordinator",
  "required": [
    "schemaVersion",
    "receiptId",
    "requestId",
    "eventId",
    "organizerId",
    "attendeeId",
    "uid",
    "operationId",
    "requestHash",
    "requestRevision",
    "profileRevision",
    "sourceHash",
    "fieldIds",
    "expiresAt",
    "createdAt"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "receiptId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "attendeeId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "operationId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "requestHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "requestRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "profileRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "sourceHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "fieldIds": {
      "type": "array",
      "uniqueItems": true,
      "minItems": 1,
      "maxItems": 10,
      "items": {
        "type": "string",
        "enum": [
          "displayName",
          "gender",
          "interestedInGenders",
          "relationshipGoal",
          "dateOfBirth",
          "paceBand",
          "skillBand",
          "dietaryAndSeatingNotes",
          "questionnaireAnswerIds",
          "teamName"
        ]
      }
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
      }
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
  }
} as const;
