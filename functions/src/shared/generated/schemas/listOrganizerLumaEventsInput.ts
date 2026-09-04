/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listOrganizerLumaEventsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/list_organizer_luma_events_payload.schema.json",
  "title": "ListOrganizerLumaEventsCallablePayload",
  "description": "Manager request to verify a calendar-scoped Luma API key and list manageable events without persisting the key.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "eventId",
    "apiKey"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "apiKey": {
      "type": "string",
      "minLength": 16,
      "maxLength": 512
    }
  }
} as const;
