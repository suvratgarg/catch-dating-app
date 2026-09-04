/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const resolveEventInviteLandingCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/resolve_event_invite_landing_payload.schema.json",
  "title": "ResolveEventInviteLandingCallablePayload",
  "description": "Resolves an opaque invitation bearer token into one bounded event landing projection and records a deduplicated open.",
  "x-callable-aliases": [
    "resolveEventInviteLanding"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "inviteToken"
  ],
  "properties": {
    "inviteToken": {
      "type": "string",
      "pattern": "^v2_[A-Za-z0-9_-]{1,180}_[A-Za-z0-9_-]{43}$",
      "maxLength": 230
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
