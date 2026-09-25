/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programDoorJournalDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/program_door_journal.schema.json",
  "title": "ProgramDoorJournalDocument",
  "description": "Server-owned append-only door journal entry for one program function. The document id is the deterministic journalId derived from (scope, functionId, guestId, action, occurredAtMillis, actorUid), so device retries and offline outbox replays collapse to one entry. Attendance truth projects from this journal onto programFunctionGuests.attendanceStatus; clients never write either surface directly.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "programDoorJournal",
  "x-firestore-path": "programDoorJournal/{journalId}",
  "x-document-id-field": "journalId",
  "x-owner": "program door journal callables",
  "required": [
    "programId",
    "organizerId",
    "functionId",
    "guestId",
    "actorUid",
    "action",
    "occurredAtMillis",
    "deviceId",
    "partySize",
    "note",
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
      "maxLength": 180,
      "description": "programGuests member the entry acts on; walkInCreate entries may name a guest the function never invited."
    },
    "actorUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "description": "Staff uid who recorded the action at the door."
    },
    "action": {
      "type": "string",
      "enum": [
        "checkIn",
        "undoCheckIn",
        "markNoShow",
        "walkInCreate",
        "partySizeAdjust"
      ]
    },
    "occurredAtMillis": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991,
      "description": "Client-declared action time folded into the idempotency key and journal ordering."
    },
    "deviceId": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 180,
      "description": "Door device identifier for audit; null when the device supplies none."
    },
    "partySize": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 1,
      "maximum": 20,
      "description": "Attending party size set by walkInCreate or partySizeAdjust; null on every other action."
    },
    "note": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 500,
      "description": "Optional door note such as a late-arrival explanation."
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
