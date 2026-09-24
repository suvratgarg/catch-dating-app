/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programGuestDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/program_guests.schema.json",
  "title": "ProgramGuestDocument",
  "description": "Server-owned person-level wedding/corporate guest record. One document per invited person; household membership and optional CRM contact links are explicit. A shared phone number never merges two guests.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "programGuests",
  "x-firestore-path": "programGuests/{guestId}",
  "x-document-id-field": "guestId",
  "x-owner": "program guest management and reviewed conversion callables",
  "required": [
    "programId",
    "organizerId",
    "displayName",
    "householdId",
    "contactId",
    "phoneE164",
    "email",
    "externalReference",
    "invitationStatus",
    "rsvpStatus",
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
    "displayName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 140
    },
    "householdId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "contactId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180,
      "description": "Optional link to organizerContacts. Absence never blocks guest operations."
    },
    "phoneE164": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 20,
      "description": "Optional reachable phone for this person. Shared family phones do not merge identities."
    },
    "email": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 320
    },
    "externalReference": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 180,
      "description": "Planner-side reference such as a spreadsheet id or invitation code."
    },
    "invitationStatus": {
      "type": "string",
      "enum": [
        "notInvited",
        "invited",
        "delivered",
        "responded"
      ]
    },
    "rsvpStatus": {
      "type": "string",
      "enum": [
        "pending",
        "attending",
        "declined",
        "maybe"
      ],
      "description": "Derived program-wide rollup maintained by the server from programFunctionGuests rows (any attending -> attending, else strongest other response). Per-function truth lives only on programFunctionGuests; writers never set this directly."
    },
    "source": {
      "type": "string",
      "enum": [
        "manual",
        "import",
        "formResponse"
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
