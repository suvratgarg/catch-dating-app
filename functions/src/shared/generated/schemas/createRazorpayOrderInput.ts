/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const createRazorpayOrderCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/create_razorpay_order_payload.schema.json",
  "title": "CreateRazorpayOrderCallablePayload",
  "description": "Callable payload accepted by createRazorpayOrder. Returns a Razorpay order id + amount that the client uses to open the checkout sheet.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "inviteCode": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 4,
      "maxLength": 64,
      "pattern": "^[A-Za-z0-9_-]+$"
    },
    "inviteLinkId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "crossPathsPairHoldId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
