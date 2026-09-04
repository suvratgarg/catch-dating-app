/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const claimEventRuntimeAccessCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/claim_event_runtime_access_payload.schema.json",
  "title": "ClaimEventRuntimeAccessCallablePayload",
  "description": "Claims one operational attendee after Firebase phone verification.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "publicRuntimeId",
    "displayName",
    "runtimeTermsVersion"
  ],
  "properties": {
    "publicRuntimeId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{20,80}$"
    },
    "displayName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "runtimeTermsVersion": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80
    },
    "attendeeToken": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 20,
      "maxLength": 240
    },
    "inviteToken": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180,
      "description": "Legacy invite-link id or versioned opaque invitation bearer token."
    }
  }
} as const;
