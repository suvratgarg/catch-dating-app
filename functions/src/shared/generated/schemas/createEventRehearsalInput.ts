/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const createEventRehearsalCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/create_event_rehearsal_payload.schema.json",
  "title": "CreateEventRehearsalCallablePayload",
  "description": "Creates an isolated rehearsal from a real event snapshot or the safe sample template.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "sourceEventId",
    "scenarioId",
    "seed",
    "actorCount"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "sourceEventId": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 180
    },
    "scenarioId": {
      "type": "string",
      "enum": [
        "smoothRun",
        "lateAndNoShow",
        "earlyExitAndReturn",
        "rosterAndCapacity",
        "walkInAndAmbiguousClaim",
        "privacyAndKeepApart",
        "lowConnectivity",
        "concurrentHosts",
        "revealInterrupted",
        "externalProfiles",
        "accountabilitySweep"
      ]
    },
    "seed": {
      "type": "integer",
      "minimum": 1,
      "maximum": 2147483647
    },
    "actorCount": {
      "type": "integer",
      "minimum": 2,
      "maximum": 50
    }
  }
} as const;
