/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const transportActiveAssignmentDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/transport_active_assignments.schema.json",
  "title": "TransportActiveAssignmentDocument",
  "description": "Server-owned unique binding from a travel leg to its active trip. Created in the same transaction as dispatch so two staff cannot board one leg twice.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "transportActiveAssignments",
  "x-firestore-path": "transportActiveAssignments/{assignmentId}",
  "x-document-id-field": "assignmentId",
  "x-owner": "program dispatch transaction",
  "required": [
    "programId",
    "legId",
    "tripId",
    "status",
    "assignedAt",
    "releasedAt",
    "revision"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "legId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "tripId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "status": {
      "type": "string",
      "enum": [
        "active",
        "released"
      ]
    },
    "assignedAt": {
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
    "releasedAt": {
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
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    }
  }
} as const;
