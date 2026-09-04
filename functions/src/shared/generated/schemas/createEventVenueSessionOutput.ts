/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const createEventVenueSessionCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/create_event_venue_session_response.schema.json",
  "title": "CreateEventVenueSessionCallableResponse",
  "description": "Short-lived signed venue session returned only to an authorized Host manager.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "venueSessionToken",
    "expiresAtMillis",
    "refreshAfterMillis"
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
    },
    "expiresAtMillis": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "refreshAfterMillis": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    }
  }
} as const;
