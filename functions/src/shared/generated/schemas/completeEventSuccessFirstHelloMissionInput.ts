/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const completeEventSuccessFirstHelloMissionCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/complete_event_success_first_hello_mission_payload.schema.json",
  "title": "CompleteEventSuccessFirstHelloMissionCallablePayload",
  "description": "Callable payload accepted by completeEventSuccessFirstHelloMission.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "answerId"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "answerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 64
    }
  }
} as const;
