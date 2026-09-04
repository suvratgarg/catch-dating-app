/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const recordEventShareIntentCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/record_event_share_intent_payload.schema.json",
  "title": "RecordEventShareIntentCallablePayload",
  "description": "Records that a signed-in actor opened a Catch share surface. It never claims a message was sent or forwarded.",
  "x-callable-aliases": [
    "recordEventShareIntent"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "inviteLinkId",
    "surface"
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
        "hostApp",
        "consumerApp",
        "runtimeWeb"
      ]
    },
    "creativeId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "channelHint": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        "systemShare",
        "copyLink",
        "whatsapp",
        "sms",
        "email",
        null
      ]
    }
  }
} as const;
