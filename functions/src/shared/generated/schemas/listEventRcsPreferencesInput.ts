/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listEventRcsPreferencesCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "additionalProperties": false,
  "$id": "https://catch.app/contracts/callables/list_event_rcs_preferences_payload.schema.json",
  "title": "ListEventRcsPreferencesCallablePayload",
  "required": [
    "eventId",
    "attendeeId",
    "cursor"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]{0,159}$"
    },
    "attendeeId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]{0,159}$"
    },
    "cursor": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^rcs-permission:[a-f0-9]{64}$"
    }
  }
} as const;
