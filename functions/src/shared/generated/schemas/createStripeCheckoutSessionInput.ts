/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const createStripeCheckoutSessionCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/create_stripe_checkout_session_payload.schema.json",
  "title": "CreateStripeCheckoutSessionCallablePayload",
  "description": "Callable payload accepted by createStripeCheckoutSession. The server derives amount, currency, host account, and booking metadata from Firestore.",
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
      "maxLength": 80
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
