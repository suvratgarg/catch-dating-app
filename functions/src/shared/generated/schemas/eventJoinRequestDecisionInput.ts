/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventJoinRequestDecisionCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/event_join_request_decision_payload.schema.json",
  "title": "EventJoinRequestDecisionCallablePayload",
  "description": "Callable payload accepted by decideEventJoinRequest.",
  "x-callable-aliases": [
    "decideEventJoinRequest"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "userId",
    "decision"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "userId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "decision": {
      "type": "string",
      "enum": [
        "approve",
        "decline"
      ]
    }
  }
} as const;
