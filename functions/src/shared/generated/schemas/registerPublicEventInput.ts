/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const registerPublicEventCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/register_public_event_payload.schema.json",
  "title": "RegisterPublicEventCallablePayload",
  "description": "Phone-authenticated website registration for a published Catch event without a Consumer profile.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "displayName"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "displayName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "inviteToken": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180,
      "description": "Legacy invite-link id or versioned opaque invitation bearer token."
    },
    "organizerUpdates": {
      "description": "Optional, explicit opt-in to organizer marketing updates. Absence never grants consent.",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "whatsapp",
        "sms",
        "termsVersion"
      ],
      "properties": {
        "whatsapp": {
          "type": "boolean"
        },
        "sms": {
          "type": "boolean"
        },
        "termsVersion": {
          "type": "string",
          "minLength": 1,
          "maxLength": 80
        }
      }
    }
  }
} as const;
