/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const checkInEventRuntimeCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/check_in_event_runtime_response.schema.json",
  "title": "CheckInEventRuntimeCallableResponse",
  "description": "Idempotent operational attendance result for the no-download runtime.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "status",
    "alreadyCheckedIn"
  ],
  "properties": {
    "status": {
      "const": "checkedIn"
    },
    "alreadyCheckedIn": {
      "type": "boolean"
    }
  }
} as const;
