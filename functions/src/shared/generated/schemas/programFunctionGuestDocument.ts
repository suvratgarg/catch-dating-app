/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programFunctionGuestDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/program_function_guests.schema.json",
  "title": "ProgramFunctionGuestDocument",
  "description": "Server-owned per-function invitation, RSVP and door-attendance join record. One document per (functionId, guestId) pair; the document id is the deterministic `${functionId}_${guestId}` join key so invites and responses upsert idempotently. Per-function truth lives here; programGuests.rsvpStatus is only a derived rollup.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "programFunctionGuests",
  "x-firestore-path": "programFunctionGuests/{functionGuestId}",
  "x-document-id-field": "functionGuestId",
  "x-owner": "program guest management, RSVP conversion, and function check-in callables",
  "required": [
    "programId",
    "organizerId",
    "functionId",
    "guestId",
    "invited",
    "rsvpStatus",
    "attendanceStatus",
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
    "functionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "guestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "invited": {
      "type": "boolean",
      "description": "Whether this guest is on the function's invitation list. Rows exist only for functions with invitationMode=selectedGuests when invited=false; allGuests functions may omit rows entirely."
    },
    "rsvpStatus": {
      "type": "string",
      "enum": [
        "pending",
        "attending",
        "declined",
        "maybe"
      ]
    },
    "attendanceStatus": {
      "type": "string",
      "enum": [
        "expected",
        "checkedIn",
        "noShow"
      ],
      "description": "Door/arrival state for one guest at one function. expected is the default for invited guests; noShow is marked after the function ends."
    },
    "partySize": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 1,
      "maximum": 20,
      "description": "Attending party size including children when the guest RSVPs for more than themselves; null reads as 1."
    },
    "respondedAt": {
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
      "description": "When the guest's current RSVP response was recorded; null while still pending."
    },
    "responseNote": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 500,
      "description": "Optional guest note captured with the response, such as dietary or plus-one detail."
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
