/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const recordSalesPartnerManualSendResponseSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "draftId",
    "activityId",
    "exactContentHash",
    "occurredAt",
    "outcome",
    "providerConfirmed",
    "sendAuthority"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "draftId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "activityId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "exactContentHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "occurredAt": {
      "type": "string",
      "format": "date-time",
      "maxLength": 48
    },
    "outcome": {
      "const": "actor_attested_sent"
    },
    "providerConfirmed": {
      "const": false
    },
    "sendAuthority": {
      "const": false
    }
  },
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/record_sales_partner_manual_send_response.schema.json",
  "title": "RecordSalesPartnerManualSendResponse",
  "x-callable-aliases": [
    "recordSalesPartnerManualSend"
  ]
} as const;
