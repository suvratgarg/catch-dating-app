/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventRehearsalSummaryCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/event_rehearsal_summary_response.schema.json",
  "title": "EventRehearsalSummaryCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "hasCompletedRehearsal"
  ],
  "properties": {
    "hasCompletedRehearsal": {
      "type": "boolean"
    }
  }
} as const;
