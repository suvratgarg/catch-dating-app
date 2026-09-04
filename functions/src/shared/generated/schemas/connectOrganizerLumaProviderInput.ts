/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const connectOrganizerLumaProviderCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/connect_organizer_luma_provider_payload.schema.json",
  "title": "ConnectOrganizerLumaProviderCallablePayload",
  "description": "Connect a calendar-scoped Luma API key and map one Catch event after provider verification.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "eventId",
    "externalEventId",
    "apiKey"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "externalEventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "apiKey": {
      "type": "string",
      "minLength": 16,
      "maxLength": 512
    }
  }
} as const;
