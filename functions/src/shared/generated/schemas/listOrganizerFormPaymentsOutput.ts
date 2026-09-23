/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listOrganizerFormPaymentsCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/list_organizer_form_payments_response.schema.json",
  "title": "ListOrganizerFormPaymentsCallableResponse",
  "description": "Minimal organizer fee records. No private credential, draft token, unsubmitted answers or respondent identity is exposed.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "items",
    "nextCursor"
  ],
  "properties": {
    "items": {
      "type": "array",
      "maxItems": 50,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "paymentId",
          "status",
          "mode",
          "amountPaise",
          "currency",
          "refundedAmountPaise",
          "createdAtMillis",
          "updatedAtMillis",
          "capturedAtMillis",
          "submittedAtMillis",
          "responseId",
          "providerOrderId",
          "providerPaymentId",
          "providerRefundId",
          "receipt"
        ],
        "properties": {
          "paymentId": {
            "type": "string",
            "pattern": "^fp_[a-f0-9]{32}$"
          },
          "status": {
            "enum": [
              "creatingOrder",
              "orderUnknown",
              "checkoutReady",
              "verifying",
              "captured",
              "submitted",
              "failed",
              "expired",
              "refundPending",
              "refunded",
              "reviewRequired"
            ],
            "type": "string"
          },
          "mode": {
            "type": "string",
            "enum": [
              "test",
              "live"
            ]
          },
          "amountPaise": {
            "type": "integer",
            "minimum": 100,
            "maximum": 10000000
          },
          "currency": {
            "const": "INR"
          },
          "refundedAmountPaise": {
            "type": "integer",
            "minimum": 0,
            "maximum": 10000000
          },
          "createdAtMillis": {
            "type": "integer",
            "minimum": 0,
            "maximum": 9007199254740991
          },
          "updatedAtMillis": {
            "type": "integer",
            "minimum": 0,
            "maximum": 9007199254740991
          },
          "capturedAtMillis": {
            "type": [
              "integer",
              "null"
            ],
            "minimum": 0,
            "maximum": 9007199254740991
          },
          "submittedAtMillis": {
            "type": [
              "integer",
              "null"
            ],
            "minimum": 0,
            "maximum": 9007199254740991
          },
          "responseId": {
            "anyOf": [
              {
                "type": "string",
                "minLength": 1,
                "maxLength": 180
              },
              {
                "type": "null"
              }
            ]
          },
          "providerOrderId": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 160
          },
          "providerPaymentId": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 160
          },
          "providerRefundId": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 160
          },
          "receipt": {
            "type": "string",
            "pattern": "^cfp_[a-f0-9]{32}$"
          }
        }
      }
    },
    "nextCursor": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 1000
    }
  }
} as const;
