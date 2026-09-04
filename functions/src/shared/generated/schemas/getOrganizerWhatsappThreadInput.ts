/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getOrganizerWhatsappThreadCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/get_organizer_whatsapp_thread_payload.schema.json",
  "title": "GetOrganizerWhatsappThreadCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "threadId"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "threadId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
