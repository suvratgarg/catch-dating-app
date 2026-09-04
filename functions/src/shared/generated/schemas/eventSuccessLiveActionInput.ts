/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventSuccessLiveActionCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/event_success_live_action_payload.schema.json",
  "title": "EventSuccessLiveActionCallablePayload",
  "description": "Revision-fenced live control action accepted by controlEventSuccessLive.",
  "x-callable-aliases": [
    "controlEventSuccessLive"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "expectedRevision",
    "action"
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
    "action": {
      "type": "string",
      "enum": [
        "setActiveStep",
        "startRevealCountdown",
        "cancelRevealCountdown",
        "publishReveal",
        "complete"
      ]
    },
    "activeStepIndex": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100
    },
    "roundIndex": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100
    },
    "confirmed": {
      "type": "boolean"
    },
    "accountabilityAcknowledged": {
      "type": "boolean",
      "description": "Explicit Host acknowledgement that a sweep still has unresolved checked-in attendees."
    }
  }
} as const;
