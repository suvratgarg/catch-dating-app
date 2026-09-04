/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const heartbeatEventSuccessPresenceCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/heartbeat_event_success_presence_payload.schema.json",
  "title": "HeartbeatEventSuccessPresenceCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "surface"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "surface": {
      "type": "string",
      "enum": [
        "flutter",
        "web"
      ]
    }
  }
} as const;
