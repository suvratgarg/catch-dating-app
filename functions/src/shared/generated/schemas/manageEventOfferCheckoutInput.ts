/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const manageEventOfferCheckoutCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/manage_event_offer_checkout_payload.schema.json",
  "title": "ManageEventOfferCheckoutCallablePayload",
  "oneOf": [
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "action",
        "token"
      ],
      "properties": {
        "action": {
          "const": "claim"
        },
        "token": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{43}$"
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "action",
        "grantId",
        "requestId",
        "cancellationPolicy"
      ],
      "properties": {
        "action": {
          "const": "prepare"
        },
        "grantId": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "requestId": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{8,120}$"
        },
        "cancellationPolicy": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "refundDeadlineMillis",
            "eventStartsAtMillis"
          ],
          "properties": {
            "refundDeadlineMillis": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "eventStartsAtMillis": {
              "type": "integer",
              "minimum": 1,
              "maximum": 9007199254740991
            }
          }
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "action",
        "grantId"
      ],
      "properties": {
        "action": {
          "const": "find"
        },
        "grantId": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "action",
        "paymentId",
        "callback"
      ],
      "properties": {
        "action": {
          "const": "status"
        },
        "paymentId": {
          "type": "string",
          "pattern": "^ep_[a-f0-9]{32}$"
        },
        "callback": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "paymentId",
                "signature"
              ],
              "properties": {
                "paymentId": {
                  "type": "string",
                  "pattern": "^pay_[A-Za-z0-9]+$"
                },
                "signature": {
                  "type": "string",
                  "pattern": "^[a-fA-F0-9]{64}$"
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
      "type": "object",
      "additionalProperties": false,
      "required": [
        "action",
        "paymentId",
        "expectedRefundAmountPaise"
      ],
      "properties": {
        "action": {
          "const": "cancelAdmission"
        },
        "paymentId": {
          "type": "string",
          "pattern": "^ep_[a-f0-9]{32}$"
        },
        "expectedRefundAmountPaise": {
          "type": "integer",
          "minimum": 0,
          "maximum": 100000000
        }
      }
    }
  ]
} as const;
