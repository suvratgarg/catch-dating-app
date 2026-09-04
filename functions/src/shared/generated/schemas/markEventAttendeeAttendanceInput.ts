/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const markEventAttendeeAttendanceCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/mark_event_attendee_attendance_payload.schema.json",
  "title": "MarkEventAttendeeAttendanceCallablePayload",
  "description": "Callable payload accepted by markEventAttendeeAttendance.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "attendeeId"
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
    }
  }
} as const;
