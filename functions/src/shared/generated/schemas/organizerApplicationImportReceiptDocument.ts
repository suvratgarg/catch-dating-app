/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerApplicationImportReceiptDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_application_import_receipts.schema.json",
  "title": "OrganizerApplicationImportReceiptDocument",
  "description": "Idempotency and result receipt for one bounded application import commit.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerApplicationImportReceipts",
  "x-firestore-path": "organizerApplicationImportReceipts/{receiptId}",
  "x-document-id-field": "receiptId",
  "x-owner": "organizer application import callable",
  "required": [
    "organizerId",
    "formId",
    "formVersionId",
    "mappingId",
    "uploadedByUid",
    "importKey",
    "fileName",
    "format",
    "payloadHash",
    "status",
    "rowCount",
    "createdCount",
    "skippedCount",
    "errors",
    "createdAt",
    "completedAt"
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
    "formVersionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "mappingId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    },
    "uploadedByUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "importKey": {
      "type": "string",
      "minLength": 8,
      "maxLength": 120
    },
    "fileName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 255
    },
    "format": {
      "type": "string",
      "enum": [
        "csv",
        "xlsx",
        "connector"
      ]
    },
    "payloadHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "status": {
      "type": "string",
      "enum": [
        "completed",
        "partial",
        "failed"
      ]
    },
    "rowCount": {
      "type": "integer",
      "minimum": 1,
      "maximum": 200
    },
    "createdCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 200
    },
    "skippedCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 200
    },
    "errors": {
      "type": "array",
      "maxItems": 100,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "rowId",
          "code",
          "message"
        ],
        "properties": {
          "rowId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
          },
          "code": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "message": {
            "type": "string",
            "minLength": 1,
            "maxLength": 240
          }
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
    },
    "completedAt": {
      "anyOf": [
        {
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
        {
          "type": "null"
        }
      ]
    }
  }
} as const;
