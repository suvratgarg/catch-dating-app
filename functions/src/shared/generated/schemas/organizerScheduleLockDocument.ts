/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerScheduleLockDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_schedule_locks.schema.json",
  "title": "OrganizerScheduleLockDocument",
  "description": "Server-owned time-slot claim stored at organizerScheduleLocks/{organizerId_slot}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerScheduleLocks",
  "x-firestore-path": "organizerScheduleLocks/{lockId}",
  "x-document-id-field": "lockId",
  "x-owner": "event schedule conflict callables",
  "required": [
    "ownerType",
    "ownerId",
    "slot",
    "eventId",
    "organizerId",
    "startTimeMillis",
    "endTimeMillis"
  ],
  "properties": {
    "ownerType": {
      "type": "string",
      "const": "organizer",
      "x-catch-ownership": "callable-owned"
    },
    "ownerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "slot": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "callable-owned"
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "startTimeMillis": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "callable-owned"
    },
    "endTimeMillis": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "callable-owned"
    }
  }
} as const;
