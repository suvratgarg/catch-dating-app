/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programStaffGrantDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/program_staff_grants.schema.json",
  "title": "ProgramStaffGrantDocument",
  "description": "Server-owned, expiring program staff access. Duties are named and station-scoped; a grant never confers organizer, CRM, messaging or cross-program authority.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "programStaffGrants",
  "x-firestore-path": "programStaffGrants/{grantId}",
  "x-document-id-field": "grantId",
  "x-owner": "program staff access callables",
  "required": [
    "organizerId",
    "programId",
    "uid",
    "displayName",
    "phoneLastFour",
    "duties",
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
    "programId": {
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
    "duties": {
      "type": "array",
      "minItems": 1,
      "maxItems": 8,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "duty",
          "pickupPointIds",
          "hotelIds",
          "expiresAtMillis"
        ],
        "properties": {
          "duty": {
            "type": "string",
            "enum": [
              "programCoordinator",
              "guestRelations",
              "communications",
              "functionCheckIn",
              "functionLead",
              "airportGreeter",
              "hotelDesk",
              "transportDispatcher",
              "reconciliationViewer",
              "stakeholderViewer"
            ]
          },
          "pickupPointIds": {
            "type": "array",
            "maxItems": 32,
            "uniqueItems": true,
            "items": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "description": "Pickup restriction; empty means all program pickup points. Both resource restrictions must be met by the same assignment."
          },
          "hotelIds": {
            "type": "array",
            "maxItems": 64,
            "uniqueItems": true,
            "items": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "description": "Destination restriction; empty means all program hotels. Restrictions from different assignments never combine into new routes."
          },
          "functionIds": {
            "type": "array",
            "maxItems": 64,
            "uniqueItems": true,
            "items": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "description": "Function restriction for functionCheckIn and functionLead duties; absent or empty means all program functions. Optional on documents written before function-scoped duties existed."
          },
          "expiresAtMillis": {
            "type": "integer",
            "minimum": 1,
            "maximum": 9007199254740991,
            "description": "Exclusive expiry of this exact duty and resource scope. Independent of other assignments."
          }
        }
      },
      "description": "Up to eight independently expiring scope tuples. Identical tuples may be renewed; different tuples remain separate."
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
      "description": "Maximum assignment expiry for indexed grant inventory; authorization also checks each assignment expiry.",
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
    }
  }
} as const;
