/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const recordEventInviteLinkOpenCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/record_event_invite_link_open_payload.schema.json",
  "title": "RecordEventInviteLinkOpenCallablePayload",
  "description": "Callable payload accepted by recordEventInviteLinkOpen. inviteLinkId accepts a legacy document id or a versioned opaque bearer token.",
  "x-callable-aliases": [
    "recordEventInviteLinkOpen"
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
    },
    "surface": {
      "type": "string",
      "enum": [
        "consumerApp",
        "hostApp",
        "runtimeWeb",
        "marketingWeb",
        "unknown"
      ]
    },
    "sessionId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 8,
      "maxLength": 128
    }
  }
} as const;
