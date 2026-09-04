/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventIdCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/event_id_payload.schema.json",
  "title": "EventIdCallablePayload",
  "description": "Callable payload accepted by simple event actions that need only an eventId (plus optional inviteCode for invite-gated events).",
  "x-callable-aliases": [
    "cancelEventSignUp",
    "deleteEvent",
    "fetchEventSuccessWingmanCandidates",
    "fetchSwipeCandidates",
    "generateEventSuccessPods",
    "generateEventSuccessRotations",
    "acceptEventWaitlistOffer",
    "declineEventWaitlistOffer",
    "joinEventWaitlist",
    "leaveEventWaitlist",
    "withdrawEventSuccessWingmanRequest"
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
    }
  }
} as const;
