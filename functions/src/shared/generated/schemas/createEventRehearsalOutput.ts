/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const createEventRehearsalCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/create_event_rehearsal_response.schema.json",
  "title": "CreateEventRehearsalCallableResponse",
  "description": "Identifiers and guest link returned when a rehearsal is created.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "sessionId",
    "guestUrl",
    "setupRevision",
    "runtimeRevision"
  ],
  "properties": {
    "sessionId": {
      "type": "string"
    },
    "guestUrl": {
      "type": "string"
    },
    "setupRevision": {
      "type": "integer"
    },
    "runtimeRevision": {
      "type": "integer"
    }
  }
} as const;
