/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const startEventSuccessFirstHelloMissionCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/start_event_success_first_hello_mission_payload.schema.json",
  "title": "StartEventSuccessFirstHelloMissionCallablePayload",
  "description": "Callable payload accepted by startEventSuccessFirstHelloMission.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "venueSessionToken"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "venueSessionToken": {
      "type": "string",
      "minLength": 64,
      "maxLength": 2048
    }
  }
} as const;
