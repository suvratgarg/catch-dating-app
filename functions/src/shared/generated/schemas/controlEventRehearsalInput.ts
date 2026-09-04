/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const controlEventRehearsalCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/control_event_rehearsal_payload.schema.json",
  "title": "ControlEventRehearsalCallablePayload",
  "description": "Revision-fenced Host lifecycle or virtual-clock control.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "sessionId",
    "expectedRevision",
    "clientActionId",
    "action"
  ],
  "properties": {
    "sessionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 2147483647
    },
    "clientActionId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{8,120}$"
    },
    "action": {
      "type": "string",
      "enum": [
        "markReady",
        "start",
        "pause",
        "resume",
        "advance",
        "previous",
        "advanceClock",
        "complete"
      ]
    },
    "minutes": {
      "type": "integer",
      "minimum": 1,
      "maximum": 120
    }
  }
} as const;
