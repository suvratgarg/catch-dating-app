/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getOrganizerFormPaymentCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/get_organizer_form_payment_response.schema.json",
  "title": "GetOrganizerFormPaymentCallableResponse",
  "description": "Owner-only safe payment projection.",
  "allOf": [
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "paymentId",
        "status",
        "amountPaise",
        "currency",
        "mode",
        "refundPolicy",
        "refundedAmountPaise",
        "checkout",
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
        "amountPaise": {
          "type": "integer",
          "minimum": 100,
          "maximum": 10000000
        },
        "currency": {
          "const": "INR"
        },
        "mode": {
          "type": "string",
          "enum": [
            "test",
            "live"
          ]
        },
        "refundPolicy": {
          "type": "string",
          "minLength": 1,
          "maxLength": 1000
        },
        "refundedAmountPaise": {
          "type": "integer",
          "minimum": 0
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
                  "pattern": "^rzp_(test|live)_oauth_[A-Za-z0-9]+$"
                },
                "orderId": {
                  "type": "string",
                  "pattern": "^order_[A-Za-z0-9]+$"
                },
                "amountPaise": {
                  "type": "integer",
                  "minimum": 100,
                  "maximum": 10000000
                },
                "currency": {
                  "const": "INR"
                },
                "description": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160
                },
                "expiresAtMillis": {
                  "type": "integer",
                  "minimum": 0
                }
              }
            },
            {
              "type": "null"
            }
          ]
        },
        "receipt": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "responseId",
                "formId",
                "versionId",
                "status",
                "submittedAtMillis",
                "withdrawalToken",
                "completion"
              ],
              "properties": {
                "responseId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                },
                "formId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                },
                "versionId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                },
                "status": {
                  "type": "string",
                  "enum": [
                    "submitted",
                    "withdrawn"
                  ]
                },
                "submittedAtMillis": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "withdrawalToken": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "pattern": "^[A-Za-z0-9_-]{32,160}$"
                },
                "completion": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "title",
                    "message",
                    "actionKind",
                    "actionLabel",
                    "actionUrl"
                  ],
                  "properties": {
                    "title": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160
                    },
                    "message": {
                      "type": [
                        "string",
                        "null"
                      ],
                      "maxLength": 1000
                    },
                    "actionKind": {
                      "type": "string",
                      "enum": [
                        "none",
                        "externalUrl",
                        "event",
                        "eventRuntime"
                      ]
                    },
                    "actionLabel": {
                      "type": [
                        "string",
                        "null"
                      ],
                      "maxLength": 80
                    },
                    "actionUrl": {
                      "type": [
                        "string",
                        "null"
                      ],
                      "format": "uri",
                      "maxLength": 500
                    }
                  }
                }
              }
            },
            {
              "type": "null"
            }
          ]
        }
      }
    }
  ]
} as const;
