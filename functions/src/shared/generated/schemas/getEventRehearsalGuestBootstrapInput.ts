/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getEventRehearsalGuestBootstrapCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/get_event_rehearsal_guest_bootstrap_payload.schema.json",
  "title": "GetEventRehearsalGuestBootstrapCallablePayload",
  "description": "Redeems or refreshes an anonymous rehearsal guest view.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "publicRehearsalId",
    "clientInstanceId",
    "viewerToken",
    "slotToken"
  ],
  "properties": {
    "publicRehearsalId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{20,80}$"
    },
    "clientInstanceId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{16,80}$"
    },
    "viewerToken": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 120
    },
    "slotToken": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 180
    }
  }
} as const;
