/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const markEventAttendanceCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/mark_event_attendance_payload.schema.json",
  "title": "MarkEventAttendanceCallablePayload",
  "description": "Callable payload accepted by markEventAttendance.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "userId"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "userId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
