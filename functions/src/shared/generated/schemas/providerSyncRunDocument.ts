/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const providerSyncRunDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/provider_sync_runs.schema.json",
  "title": "ProviderSyncRunDocument",
  "description": "Idempotent audit and replay receipt for one external-provider event reconciliation.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "providerSyncRuns",
  "x-firestore-path": "providerSyncRuns/{runId}",
  "x-document-id-field": "runId",
  "x-owner": "organizer provider roster reconciliation callable",
  "required": [
    "organizerId",
    "eventId",
    "connectionId",
    "mappingId",
    "provider",
    "clientOperationId",
    "inputHash",
    "status",
    "pageCount",
    "receivedCount",
    "createdCount",
    "updatedCount",
    "skippedCount",
    "truncated",
    "errorCode",
    "startedByUid",
    "startedAt",
    "completedAt",
    "expiresAt"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "connectionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "mappingId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "provider": {
      "const": "luma"
    },
    "clientOperationId": {
      "type": "string",
      "minLength": 16,
      "maxLength": 120
    },
    "inputHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "status": {
      "type": "string",
      "enum": [
        "running",
        "completed",
        "partial",
        "failed"
      ]
    },
    "pageCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 10
    },
    "receivedCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 250
    },
    "createdCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 250
    },
    "updatedCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 250
    },
    "skippedCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 250
    },
    "truncated": {
      "type": "boolean"
    },
    "errorCode": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 80
    },
    "startedByUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "startedAt": {
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
    }
  }
} as const;
