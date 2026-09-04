/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const selfCheckInAttendanceCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/self_check_in_attendance_payload.schema.json",
  "title": "SelfCheckInAttendanceCallablePayload",
  "description": "Callable payload accepted by selfCheckInAttendance.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "venueSessionToken"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "venueSessionToken": {
      "type": "string",
      "minLength": 64,
      "maxLength": 2048
    }
  }
} as const;
