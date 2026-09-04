/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const resolveEventSuccessLateArrivalCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/resolve_event_success_late_arrival_response.schema.json",
  "title": "ResolveEventSuccessLateArrivalCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "status",
    "targetRoundIndex",
    "revision",
    "assignmentDraftRevision",
    "reason",
    "replayed"
  ],
  "properties": {
    "status": {
      "type": "string",
      "enum": [
        "insertedIntoOpenPair",
        "extendedUnit",
        "heldForNextRound"
      ]
    },
    "targetRoundIndex": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100
    },
    "revision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 2147483647
    },
    "assignmentDraftRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 2147483647
    },
    "reason": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "replayed": {
      "type": "boolean"
    }
  }
} as const;
