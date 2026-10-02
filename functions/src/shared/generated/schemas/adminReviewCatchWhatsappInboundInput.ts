/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminReviewCatchWhatsappInboundCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_review_catch_whatsapp_inbound_payload.schema.json",
  "title": "AdminReviewCatchWhatsappInboundCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "purpose",
    "inboundEventId"
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
    }
  }
} as const;
