/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const externalEventMappingDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/external_event_mappings.schema.json",
  "title": "ExternalEventMappingDocument",
  "description": "Stable mapping and field-level authority between one Catch event and one organizer-authorized booking-provider event.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "externalEventMappings",
  "x-firestore-path": "externalEventMappings/{mappingId}",
  "x-document-id-field": "mappingId",
  "x-owner": "organizer provider mapping and roster reconciliation callables",
  "required": [
    "organizerId",
    "eventId",
    "connectionId",
    "provider",
    "externalEventId",
    "status",
    "fieldAuthority",
    "revision",
    "createdByUid",
    "createdAt",
    "updatedAt",
    "lastSyncAt",
    "lastSuccessfulSyncAt",
    "lastSyncStatus",
    "lastSyncRunId",
    "disconnectedAt"
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
    "provider": {
      "const": "luma"
    },
    "externalEventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "status": {
      "type": "string",
      "enum": [
        "active",
        "paused",
        "disconnected"
      ]
    },
    "fieldAuthority": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "rosterIdentity",
        "registrationStatus",
        "checkIn",
        "orderAmount",
        "refundStatus",
        "referralCode"
      ],
      "properties": {
        "rosterIdentity": {
          "const": "provider"
        },
        "registrationStatus": {
          "const": "provider"
        },
        "checkIn": {
          "const": "providerWhenPresent"
        },
        "orderAmount": {
          "const": "unavailable"
        },
        "refundStatus": {
          "const": "unavailable"
        },
        "referralCode": {
          "const": "unavailable"
        }
      }
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "createdByUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
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
    },
    "lastSyncAt": {
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
    "lastSuccessfulSyncAt": {
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
    "lastSyncStatus": {
      "type": "string",
      "enum": [
        "never",
        "running",
        "completed",
        "partial",
        "failed"
      ]
    },
    "lastSyncRunId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "disconnectedAt": {
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
