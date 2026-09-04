/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const rotateEventRehearsalGuestLinkCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/rotate_event_rehearsal_guest_link_payload.schema.json",
  "title": "RotateEventRehearsalGuestLinkCallablePayload",
  "description": "Revokes prior anonymous viewer tokens and returns a new guest link.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "sessionId"
  ],
  "properties": {
    "sessionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
