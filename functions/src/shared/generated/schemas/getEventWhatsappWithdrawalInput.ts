/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getEventWhatsappWithdrawalCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/get_event_whatsapp_withdrawal_payload.schema.json",
  "title": "GetEventWhatsappWithdrawalCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "linkId",
    "secret"
  ],
  "properties": {
    "linkId": {
      "type": "string",
      "pattern": "^[a-f0-9]{32}$"
    },
    "secret": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{43}$"
    }
  }
} as const;
