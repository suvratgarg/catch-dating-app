/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getEventRehearsalBootstrapCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/get_event_rehearsal_bootstrap_payload.schema.json",
  "title": "GetEventRehearsalBootstrapCallablePayload",
  "description": "Returns Host-safe rehearsal state.",
  "x-callable-aliases": [
    "completeEventRehearsal",
    "exportEventRehearsalReproduction"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "sessionId"
  ],
  "properties": {
    "sessionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
