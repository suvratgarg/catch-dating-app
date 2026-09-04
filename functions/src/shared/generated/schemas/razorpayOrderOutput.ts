/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const razorpayOrderCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/razorpay_order_response.schema.json",
  "title": "RazorpayOrderCallableResponse",
  "description": "Callable response returned by createRazorpayOrder.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "orderId",
    "amount",
    "currency",
    "keyId"
  ],
  "properties": {
    "orderId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "amount": {
      "type": "integer",
      "minimum": 1,
      "maximum": 100000000
    },
    "currency": {
      "type": "string",
      "pattern": "^[A-Z]{3}$"
    },
    "keyId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "description": "Public Razorpay checkout key id from the same server environment that created the order. This is not the secret key."
    }
  }
} as const;
