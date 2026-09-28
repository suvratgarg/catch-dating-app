/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programRoomBlockDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/program_room_blocks.schema.json",
  "title": "ProgramRoomBlockDocument",
  "description": "Server-owned reserved room inventory at a programHotels doc — a labelled block of rooms held for a stay window, optionally earmarked for guest groups. Stays consume capacity through roomBlockId; assignedCount is the server-maintained rollup.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "programRoomBlocks",
  "x-firestore-path": "programRoomBlocks/{roomBlockId}",
  "x-document-id-field": "roomBlockId",
  "x-owner": "program accommodation callables",
  "required": [
    "programId",
    "organizerId",
    "hotelId",
    "label",
    "roomType",
    "totalRooms",
    "assignedCount",
    "heldForGroupIds",
    "startsAt",
    "endsAt",
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
    "hotelId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "description": "programHotels doc this block reserves rooms at; must belong to the same program."
    },
    "label": {
      "type": "string",
      "minLength": 1,
      "maxLength": 140,
      "description": "Organizer-facing block name, e.g. 'Bride family — Deluxe'."
    },
    "roomType": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 140,
      "description": "Optional hotel room class (Deluxe, Suite). Null when the block is type-agnostic."
    },
    "totalRooms": {
      "type": "integer",
      "minimum": 1,
      "maximum": 500,
      "description": "Rooms held under this block."
    },
    "assignedCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 500,
      "description": "Server-maintained count of live programStays rows bound to this block; never written by clients."
    },
    "heldForGroupIds": {
      "type": "array",
      "maxItems": 12,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      },
      "description": "programGuestGroups this block is earmarked for; allocation prefers matching groups before general inventory."
    },
    "startsAt": {
      "type": "object",
      "description": "First night of the stay window this block covers.",
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
      "description": "Checkout day of the stay window this block covers.",
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
    "notes": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 500,
      "description": "Operational notes visible to organizer and hotel desk (rate contact, holding conditions)."
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
