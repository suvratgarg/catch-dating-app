/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminSendCatchWhatsappReplyCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_send_catch_whatsapp_reply_payload.schema.json",
  "title": "AdminSendCatchWhatsappReplyCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "purpose",
    "inboundEventId",
    "reviewedInboundTextHash",
    "confirmSupportRequest",
    "body"
  ],
  "properties": {
    "purpose": {
      "type": "string",
      "const": "serviceSupport"
    },
    "inboundEventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 69,
      "pattern": "^cwhe_[a-f0-9]{64}$"
    },
    "reviewedInboundTextHash": {
      "type": "string",
      "minLength": 1,
      "maxLength": 64,
      "pattern": "^[a-f0-9]{64}$"
    },
    "confirmSupportRequest": {
      "type": "boolean",
      "const": true
    },
    "body": {
      "type": "string",
      "minLength": 1,
      "maxLength": 4096
    }
  }
} as const;
