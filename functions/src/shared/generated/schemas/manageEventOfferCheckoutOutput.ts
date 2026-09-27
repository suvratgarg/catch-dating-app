/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const manageEventOfferCheckoutCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/manage_event_offer_checkout_response.schema.json",
  "title": "ManageEventOfferCheckoutCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "grant",
    "payment",
    "serverTimeMillis"
  ],
  "properties": {
    "grant": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "grantId",
            "eventName",
            "eventId",
            "startTimeMillis",
            "amountPaise",
            "currency",
            "expiresAtMillis"
          ],
          "properties": {
            "grantId": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "eventName": {
              "type": "string",
              "minLength": 1,
              "maxLength": 200
            },
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180,
              "pattern": "^[A-Za-z0-9_:-]+$"
            },
            "startTimeMillis": {
              "type": "integer",
              "minimum": 1,
              "maximum": 9007199254740991
            },
            "amountPaise": {
              "type": "integer",
              "minimum": 100,
              "maximum": 100000000
            },
            "currency": {
              "const": "INR"
            },
            "expiresAtMillis": {
              "type": "integer",
              "minimum": 1,
              "maximum": 9007199254740991
            }
          }
        },
        {
          "type": "null"
        }
      ]
    },
    "payment": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "paymentId",
            "status",
            "amountPaise",
            "currency",
            "mode",
            "refundedAmountPaise",
            "expiresAtMillis",
            "checkout"
          ],
          "properties": {
            "paymentId": {
              "type": "string",
              "pattern": "^ep_[a-f0-9]{32}$"
            },
            "status": {
              "enum": [
                "creatingOrder",
                "orderUnknown",
                "checkoutReady",
                "verifying",
                "captured",
                "admitted",
                "expired",
                "refundPending",
                "refunded",
                "reviewRequired",
                "failed"
              ]
            },
            "amountPaise": {
              "type": "integer",
              "minimum": 100,
              "maximum": 100000000
            },
            "currency": {
              "const": "INR"
            },
            "mode": {
              "enum": [
                "test",
                "live"
              ]
            },
            "refundedAmountPaise": {
              "type": "integer",
              "minimum": 0,
              "maximum": 100000000
            },
            "expiresAtMillis": {
              "type": "integer",
              "minimum": 1,
              "maximum": 9007199254740991
            },
            "checkout": {
              "anyOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "publicToken",
                    "orderId",
                    "amountPaise",
                    "currency",
                    "description",
                    "expiresAtMillis"
                  ],
                  "properties": {
                    "publicToken": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 512
                    },
                    "orderId": {
                      "type": "string",
                      "pattern": "^order_[A-Za-z0-9]+$"
                    },
                    "amountPaise": {
                      "type": "integer",
                      "minimum": 100,
                      "maximum": 100000000
                    },
                    "currency": {
                      "const": "INR"
                    },
                    "description": {
                      "type": "string",
                      "maxLength": 200
                    },
                    "expiresAtMillis": {
                      "type": "integer",
                      "minimum": 1,
                      "maximum": 9007199254740991
                    }
                  }
                },
                {
                  "type": "null"
                }
              ]
            }
          }
        },
        {
          "type": "null"
        }
      ]
    },
    "serverTimeMillis": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    }
  }
} as const;
