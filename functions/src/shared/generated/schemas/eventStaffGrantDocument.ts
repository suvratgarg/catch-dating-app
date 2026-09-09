/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventStaffGrantDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_staff_grants.schema.json",
  "title": "EventStaffGrantDocument",
  "description": "Server-owned, expiring event staff access. Event-wide operator permissions and group duties have independent expiry and authority; neither grants organizer or CRM access.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventStaffGrants",
  "x-firestore-path": "eventStaffGrants/{grantId}",
  "x-document-id-field": "grantId",
  "x-owner": "event staff access callables",
  "required": [
    "organizerId",
    "eventId",
    "uid",
    "displayName",
    "phoneLastFour",
    "role",
    "permissions",
    "status",
    "createdBy",
    "createdAt",
    "expiresAt",
    "revokedBy",
    "revokedAt",
    "updatedAt",
    "revision"
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
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "displayName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "phoneLastFour": {
      "type": "string",
      "pattern": "^[0-9]{4}$"
    },
    "role": {
      "enum": [
        "checkInOperator",
        "eventOperator"
      ]
    },
    "permissions": {
      "type": "array",
      "minItems": 0,
      "maxItems": 4,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "enum": [
          "viewRoster",
          "setAttendance",
          "reviewRuntimeClaims",
          "publishLiveLocation"
        ]
      }
    },
    "status": {
      "type": "string",
      "enum": [
        "active",
        "revoked"
      ]
    },
    "createdBy": {
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
    "expiresAt": {
      "type": "object",
      "description": "Latest expiry across event-wide permissions and group duties, for staff discovery and capacity. Each authority boundary checks its own expiry.",
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
    "revokedBy": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "revokedAt": {
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
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "operatorExpiresAt": {
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
      ],
      "description": "Independent event-wide permission expiry. Missing legacy values use expiresAt; null grants no event-wide permissions."
    },
    "groupDuties": {
      "type": "array",
      "maxItems": 20,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "groupId",
          "duty",
          "expiresAtMillis",
          "sourceHash",
          "grantedBy",
          "grantedAtMillis"
        ],
        "properties": {
          "groupId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          },
          "duty": {
            "enum": [
              "lead",
              "pacer",
              "sweep"
            ]
          },
          "expiresAtMillis": {
            "type": "integer",
            "minimum": 0,
            "maximum": 9007199254740991
          },
          "sourceHash": {
            "type": "string",
            "pattern": "^[a-f0-9]{64}$"
          },
          "grantedBy": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "grantedAtMillis": {
            "type": "integer",
            "minimum": 0,
            "maximum": 9007199254740991
          }
        }
      },
      "description": "At most one independently expiring duty per configured event/group. No implied event-wide roster or check-in permission."
    }
  }
} as const;
