/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const publishEventSuccessRotationRoundCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/publish_event_success_rotation_round_payload.schema.json",
  "title": "PublishEventSuccessRotationRoundCallablePayload",
  "description": "Confirmed revision-fenced publication of one precomputed guided-rotation round.",
  "x-callable-aliases": [
    "publishEventSuccessRotationRound"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "expectedRevision",
    "roundIndex",
    "confirmed"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 2147483647
    },
    "roundIndex": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100
    },
    "confirmed": {
      "type": "boolean"
    }
  }
} as const;
