/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const setEventAttendeeAttendanceCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/set_event_attendee_attendance_payload.schema.json",
  "title": "SetEventAttendeeAttendanceCallablePayload",
  "description": "Absolute, revision-checked Host attendance mutation with an idempotent client operation id.",
  "x-callable-aliases": [
    "setEventAttendeeAttendance"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "attendeeId",
    "desiredCheckedIn",
    "expectedRevision",
    "clientOperationId"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "attendeeId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "desiredCheckedIn": {
      "type": "boolean"
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "clientOperationId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{16,120}$"
    }
  }
} as const;
