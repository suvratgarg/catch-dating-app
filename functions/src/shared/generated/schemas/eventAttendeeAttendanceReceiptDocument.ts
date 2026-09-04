/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAttendeeAttendanceReceiptDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_attendee_attendance_receipts.schema.json",
  "title": "EventAttendeeAttendanceReceiptDocument",
  "description": "Short-lived server-only idempotency receipt for one absolute Host attendance operation.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventAttendeeAttendanceReceipts",
  "x-firestore-path": "eventAttendeeAttendanceReceipts/{receiptId}",
  "x-document-id-field": "receiptId",
  "x-owner": "setEventAttendeeAttendance callable",
  "required": [
    "eventId",
    "organizerId",
    "attendeeId",
    "actorUid",
    "clientOperationId",
    "desiredCheckedIn",
    "priorRevision",
    "acceptedRevision",
    "changed",
    "createdAt",
    "expiresAt"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "attendeeId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "actorUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "clientOperationId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{16,120}$"
    },
    "desiredCheckedIn": {
      "type": "boolean"
    },
    "priorRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "acceptedRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "changed": {
      "type": "boolean"
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
    }
  }
} as const;
