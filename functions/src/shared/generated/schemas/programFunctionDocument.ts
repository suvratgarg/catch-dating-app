/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programFunctionDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/program_functions.schema.json",
  "title": "ProgramFunctionDocument",
  "description": "Server-owned private function (ceremony, reception, offsite session) inside a program. Separate from public events documents; no public read surface exists.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "programFunctions",
  "x-firestore-path": "programFunctions/{functionId}",
  "x-document-id-field": "functionId",
  "x-owner": "program management callables",
  "required": [
    "programId",
    "organizerId",
    "name",
    "startsAt",
    "endsAt",
    "venueName",
    "status",
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
    "name": {
      "type": "string",
      "minLength": 1,
      "maxLength": 140
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
    "venueName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "venueNotes": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 500
    },
    "venueLocation": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "description": "Canonical meeting location selected from Google Places or a manually pinned map coordinate.",
          "required": [
            "name",
            "latitude",
            "longitude"
          ],
          "properties": {
            "name": {
              "type": "string",
              "minLength": 1,
              "maxLength": 240
            },
            "address": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 500
            },
            "placeId": {
              "type": [
                "string",
                "null"
              ],
              "minLength": 1,
              "maxLength": 256
            },
            "latitude": {
              "type": "number",
              "minimum": -90,
              "maximum": 90
            },
            "longitude": {
              "type": "number",
              "minimum": -180,
              "maximum": 180
            },
            "notes": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 1000
            }
          }
        },
        {
          "type": "null"
        }
      ],
      "description": "Optional precise venue pin selected from Places or dropped manually; venueName remains the display string."
    },
    "dressCode": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 140,
      "description": "Short wardrobe guidance shown on invitations and reminders, such as 'Pastel formal' or 'Poolside casual'."
    },
    "instructions": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 2000,
      "description": "Guest-facing instructions for this function (entry gate, shuttle note, what to bring). Never carries staff-only detail."
    },
    "invitationMode": {
      "type": "string",
      "enum": [
        "allGuests",
        "selectedGuests"
      ],
      "description": "Absent on functions written before per-function invitations; reads as allGuests."
    },
    "checkInEnabled": {
      "type": "boolean",
      "description": "When true, functionCheckIn/functionLead duties may mark programFunctionGuests attendanceStatus at the door."
    },
    "expectedCount": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 0,
      "maximum": 1000000,
      "description": "Server-maintained rollup of attending party sizes for catering and venue counts."
    },
    "checkedInCount": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 0,
      "maximum": 1000000,
      "description": "Server-maintained rollup of programFunctionGuests attendanceStatus=checkedIn."
    },
    "status": {
      "type": "string",
      "enum": [
        "scheduled",
        "completed",
        "cancelled"
      ]
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
