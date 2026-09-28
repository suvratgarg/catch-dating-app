/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programStayDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/program_stays.schema.json",
  "title": "ProgramStayDocument",
  "description": "Server-owned per-guest stay assignment: which hotel (and optionally which room block / room label) a guest occupies, with planned dates and hotel-side progression timestamps. One document per guest per stay; guests sharing a room have separate stays with the same roomLabel.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "programStays",
  "x-firestore-path": "programStays/{stayId}",
  "x-document-id-field": "stayId",
  "x-owner": "program accommodation callables",
  "required": [
    "programId",
    "organizerId",
    "guestId",
    "hotelId",
    "roomBlockId",
    "roomLabel",
    "startsAt",
    "endsAt",
    "status",
    "roomReadyAt",
    "hotelArrivedAt",
    "notes",
    "source",
    "createdAt",
    "updatedAt",
    "revision"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "guestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "description": "Exactly one guest per stay; roommates are separate stays sharing roomLabel."
    },
    "hotelId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "description": "programHotels doc the guest stays at; must belong to the same program."
    },
    "roomBlockId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180,
      "description": "programRoomBlocks doc this stay draws capacity from; null for ad-hoc assignments outside any block."
    },
    "roomLabel": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 40,
      "description": "Physical room assignment (e.g. '412') set by the hotel desk; null until allocated."
    },
    "startsAt": {
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
      "description": "Planned check-in; null while the stay is requested but undated."
    },
    "endsAt": {
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
      "description": "Planned check-out; null while undated."
    },
    "status": {
      "type": "string",
      "enum": [
        "held",
        "confirmed",
        "checkedIn",
        "checkedOut",
        "cancelled"
      ],
      "description": "Stay lifecycle: held (reserved, not confirmed) → confirmed → checkedIn → checkedOut; cancelled releases block capacity."
    },
    "roomReadyAt": {
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
      "description": "When the hotel marked the room ready for this guest."
    },
    "hotelArrivedAt": {
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
      "description": "When the guest actually reached the hotel (hotel-desk observed)."
    },
    "notes": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 500
    },
    "source": {
      "type": "string",
      "enum": [
        "manual",
        "import",
        "planner"
      ],
      "description": "How the stay row entered the program — mirrors programTravelLegs.source."
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
