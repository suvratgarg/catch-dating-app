/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const checkInEventRuntimeCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/check_in_event_runtime_payload.schema.json",
  "title": "CheckInEventRuntimeCallablePayload",
  "description": "Checks a ready no-download participant into the linked operational attendee row.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "publicRuntimeId",
    "venueSessionToken"
  ],
  "properties": {
    "publicRuntimeId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{20,80}$"
    },
    "venueSessionToken": {
      "type": "string",
      "minLength": 64,
      "maxLength": 2048
    }
  }
} as const;
