/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getEventInviteLinkTokenCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/get_event_invite_link_token_payload.schema.json",
  "title": "GetEventInviteLinkTokenCallablePayload",
  "description": "Manager-authorized request for the shareable bearer token of one event invitation link.",
  "x-callable-aliases": [
    "getEventInviteLinkToken"
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
