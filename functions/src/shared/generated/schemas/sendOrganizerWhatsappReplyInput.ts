/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const sendOrganizerWhatsappReplyCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/send_organizer_whatsapp_reply_payload.schema.json",
  "title": "SendOrganizerWhatsappReplyCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "threadId",
    "body",
    "expectedLastInboundAtMillis",
    "idempotencyKey"
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
    },
    "body": {
      "type": "string",
      "minLength": 1,
      "maxLength": 4096
    },
    "expectedLastInboundAtMillis": {
      "type": "integer",
      "minimum": 0
    },
    "idempotencyKey": {
      "type": "string",
      "minLength": 8,
      "maxLength": 120
    }
  }
} as const;
