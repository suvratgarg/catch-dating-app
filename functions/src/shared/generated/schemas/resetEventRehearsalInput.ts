/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const resetEventRehearsalCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/reset_event_rehearsal_payload.schema.json",
  "title": "ResetEventRehearsalCallablePayload",
  "description": "Deterministically resets or forks a rehearsal run.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "sessionId",
    "fork",
    "seed"
  ],
  "properties": {
    "sessionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "fork": {
      "type": "boolean"
    },
    "seed": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 1,
      "maximum": 2147483647
    }
  }
} as const;
