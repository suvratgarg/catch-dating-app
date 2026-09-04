/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const markEventAttendanceCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/mark_event_attendance_response.schema.json",
  "title": "MarkEventAttendanceCallableResponse",
  "description": "Callable response returned by markEventAttendance.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "attended"
  ],
  "properties": {
    "attended": {
      "type": "boolean"
    }
  }
} as const;
