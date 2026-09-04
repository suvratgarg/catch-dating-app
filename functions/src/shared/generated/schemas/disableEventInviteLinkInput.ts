/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const disableEventInviteLinkCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/disable_event_invite_link_payload.schema.json",
  "title": "DisableEventInviteLinkCallablePayload",
  "description": "Callable payload accepted by disableEventInviteLink. Disabled links stop accepting new attribution but remain in host reporting.",
  "x-callable-aliases": [
    "disableEventInviteLink"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "inviteLinkId"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "inviteLinkId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
