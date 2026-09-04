/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const verifyRazorpayPaymentCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/verify_razorpay_payment_payload.schema.json",
  "title": "VerifyRazorpayPaymentCallablePayload",
  "description": "Callable payload accepted by verifyRazorpayPayment.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "paymentId",
    "orderId",
    "signature"
  ],
  "properties": {
    "paymentId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "orderId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "signature": {
      "type": "string",
      "minLength": 1,
      "maxLength": 512
    }
  }
} as const;
