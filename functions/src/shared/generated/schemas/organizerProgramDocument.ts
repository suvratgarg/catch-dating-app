/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerProgramDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_programs.schema.json",
  "title": "OrganizerProgramDocument",
  "description": "Server-owned private wedding/corporate program root. Holds organizer ownership, lifecycle, enabled capabilities and transport tuning. Never publicly readable; guest logistics live in program-scoped collections.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerPrograms",
  "x-firestore-path": "organizerPrograms/{programId}",
  "x-document-id-field": "programId",
  "x-owner": "program management callables",
  "required": [
    "organizerId",
    "kind",
    "title",
    "timezone",
    "startsAt",
    "endsAt",
    "status",
    "capabilities",
    "transportSettings",
    "createdBy",
    "createdAt",
    "updatedAt",
    "revision"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "kind": {
      "type": "string",
      "enum": [
        "wedding",
        "corporate",
        "social",
        "other"
      ]
    },
    "title": {
      "type": "string",
      "minLength": 1,
      "maxLength": 140
    },
    "timezone": {
      "type": "string",
      "minLength": 1,
      "maxLength": 60,
      "description": "IANA timezone identifier used for display and time-band boundaries."
    },
    "startsAt": {
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
    "endsAt": {
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
    "status": {
      "type": "string",
      "enum": [
        "draft",
        "active",
        "completed",
        "archived"
      ]
    },
    "capabilities": {
      "type": "array",
      "maxItems": 8,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "enum": [
          "arrivalsTransport",
          "accommodation",
          "forms",
          "messaging"
        ]
      }
    },
    "transportSettings": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "bandWindowMillis",
        "maxReadyWaitMillis",
        "domesticExitLagMillis",
        "internationalExitLagMillis",
        "vehicleClasses"
      ],
      "properties": {
        "bandWindowMillis": {
          "type": "integer",
          "minimum": 300000,
          "maximum": 7200000,
          "description": "Anchored curb-time window used by grouping suggestions. Default 30 minutes."
        },
        "maxReadyWaitMillis": {
          "type": "integer",
          "minimum": 60000,
          "maximum": 3600000,
          "description": "Ceiling on how long a physically ready party waits before a group is flagged overdue. Default 10 minutes for premium events."
        },
        "domesticExitLagMillis": {
          "type": "integer",
          "minimum": 0,
          "maximum": 7200000,
          "description": "Default landing-to-curb lag for domestic arrivals."
        },
        "internationalExitLagMillis": {
          "type": "integer",
          "minimum": 0,
          "maximum": 14400000,
          "description": "Default landing-to-curb lag for international arrivals."
        },
        "vehicleClasses": {
          "type": "array",
          "maxItems": 16,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "id",
              "label",
              "passengerCapacity",
              "luggageCapacity",
              "capabilities",
              "sortOrder"
            ],
            "properties": {
              "id": {
                "type": "string",
                "minLength": 1,
                "maxLength": 60,
                "pattern": "^[a-z0-9][a-z0-9_-]{0,59}$"
              },
              "label": {
                "type": "string",
                "minLength": 1,
                "maxLength": 60
              },
              "passengerCapacity": {
                "type": "integer",
                "minimum": 1,
                "maximum": 200
              },
              "luggageCapacity": {
                "type": "integer",
                "minimum": 0,
                "maximum": 500
              },
              "capabilities": {
                "type": "array",
                "maxItems": 12,
                "uniqueItems": true,
                "items": {
                  "type": "string",
                  "enum": [
                    "wheelchairAccessible",
                    "extraLuggage",
                    "childSeat"
                  ]
                }
              },
              "sortOrder": {
                "type": "integer",
                "minimum": 0,
                "maximum": 1000
              }
            }
          },
          "description": "Program-scoped vehicle catalog consumed by grouping suggestions; ids are unique per program."
        }
      }
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
