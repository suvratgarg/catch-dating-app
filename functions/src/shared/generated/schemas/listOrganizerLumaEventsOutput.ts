/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listOrganizerLumaEventsCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/list_organizer_luma_events_response.schema.json",
  "title": "ListOrganizerLumaEventsCallableResponse",
  "description": "Safe calendar identity and manageable Luma event choices returned after transient key verification.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "calendarName",
    "events",
    "truncated"
  ],
  "properties": {
    "calendarName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "events": {
      "type": "array",
      "maxItems": 50,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "externalEventId",
          "name",
          "startAtMillis"
        ],
        "properties": {
          "externalEventId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 240
          },
          "name": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "startAtMillis": {
            "type": "integer",
            "minimum": 0
          }
        }
      }
    },
    "truncated": {
      "type": "boolean"
    }
  }
} as const;
