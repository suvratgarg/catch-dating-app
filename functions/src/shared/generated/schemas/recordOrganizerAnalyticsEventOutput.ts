/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const recordOrganizerAnalyticsEventCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/record_organizer_analytics_event_response.schema.json",
  "title": "RecordOrganizerAnalyticsEventCallableResponse",
  "description": "Callable response returned by recordOrganizerAnalyticsEvent after an organizer analytics event is accepted.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "accepted"
  ],
  "properties": {
    "accepted": {
      "type": "boolean"
    }
  }
} as const;
