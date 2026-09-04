/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerSenderConnectionActionCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/organizer_sender_connection_action_payload.schema.json",
  "title": "OrganizerSenderConnectionActionCallablePayload",
  "description": "Manager action on one organizer-owned messaging connection.",
  "x-callable-aliases": [
    "getOrganizerMessagingSetup",
    "syncOrganizerWhatsappTemplates",
    "disconnectOrganizerWhatsappConnection"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "connectionId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
