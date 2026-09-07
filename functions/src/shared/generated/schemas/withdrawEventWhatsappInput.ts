/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const withdrawEventWhatsappCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/withdraw_event_whatsapp_payload.schema.json",
  "title": "WithdrawEventWhatsappCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "linkId",
    "secret",
    "requestId",
    "expectedRevision"
  ],
  "properties": {
    "linkId": {
      "type": "string",
      "pattern": "^[a-f0-9]{32}$"
    },
    "secret": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{43}$"
    },
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    }
  }
} as const;
