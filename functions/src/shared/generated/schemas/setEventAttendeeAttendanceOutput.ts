/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const setEventAttendeeAttendanceCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/set_event_attendee_attendance_response.schema.json",
  "title": "SetEventAttendeeAttendanceCallableResponse",
  "description": "Authoritative outcome for an absolute operational-roster attendance mutation.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "attendeeId",
    "checkedIn",
    "acceptedRevision",
    "replayed",
    "changed"
  ],
  "properties": {
    "attendeeId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "checkedIn": {
      "type": "boolean"
    },
    "acceptedRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "replayed": {
      "type": "boolean"
    },
    "changed": {
      "type": "boolean"
    }
  }
} as const;
