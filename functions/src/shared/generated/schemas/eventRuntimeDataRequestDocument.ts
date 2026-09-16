/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventRuntimeDataRequestDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_runtime_data_requests.schema.json",
  "title": "EventRuntimeDataRequestDocument",
  "description": "Current source-fenced request for missing event-scoped runtime profile data.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventRuntimeDataRequests",
  "x-firestore-path": "eventRuntimeDataRequests/{requestId}",
  "x-document-id-field": "requestId",
  "x-owner": "server-only Event Runtime required-data coordinator",
  "required": [
    "schemaVersion",
    "requestId",
    "eventId",
    "organizerId",
    "attendeeId",
    "uid",
    "revision",
    "profileRevision",
    "sourceHash",
    "operationId",
    "fieldIds",
    "completedFieldIds",
    "status",
    "requestedBy",
    "requestedAt",
    "expiresAt",
    "completedAt",
    "updatedAt"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
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
    "revision": {
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
    "operationId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
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
    "completedFieldIds": {
      "type": "array",
      "uniqueItems": true,
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
    "status": {
      "type": "string",
      "enum": [
        "pending",
        "completed"
      ]
    },
    "requestedBy": {
      "type": "string",
      "const": "systemWithinPolicy"
    },
    "requestedAt": {
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
    "updatedAt": {
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
