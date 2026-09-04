/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventBookingCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/event_booking_payload.schema.json",
  "title": "EventBookingCallablePayload",
  "description": "Callable payload accepted by signUpForFreeEvent. Same shape as EventIdCallablePayload but distinct so the booking flow can diverge without breaking the generic event-id callables.",
  "x-callable-aliases": [
    "signUpForFreeEvent"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "inviteCode": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 4,
      "maxLength": 64,
      "pattern": "^[A-Za-z0-9_-]+$"
    },
    "inviteLinkId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "crossPathsPairHoldId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
