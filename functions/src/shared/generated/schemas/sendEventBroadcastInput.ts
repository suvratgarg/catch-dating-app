/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const sendEventBroadcastCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/send_event_broadcast_payload.schema.json",
  "title": "SendEventBroadcastCallablePayload",
  "description": "Callable payload accepted by sendEventBroadcast.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "requestId",
    "eventId",
    "audience",
    "body"
  ],
  "properties": {
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "audience": {
      "type": "string",
      "enum": [
        "booked",
        "prospective",
        "everyone"
      ]
    },
    "body": {
      "type": "string",
      "minLength": 1,
      "maxLength": 500
    }
  }
} as const;
