/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const sendOrganizerWhatsappReplyCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/send_organizer_whatsapp_reply_response.schema.json",
  "title": "SendOrganizerWhatsappReplyCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "threadId",
    "messageId",
    "providerMessageId",
    "sentAtMillis",
    "replayed"
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
    "messageId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "providerMessageId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "sentAtMillis": {
      "type": "integer",
      "minimum": 0
    },
    "replayed": {
      "type": "boolean"
    }
  }
} as const;
