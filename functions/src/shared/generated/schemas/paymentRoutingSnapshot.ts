/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const paymentRoutingSnapshotSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "version",
    "purpose",
    "organizerId",
    "selection",
    "policySource",
    "appRevision",
    "organizerRevision",
    "bindingId",
    "merchantAccountId",
    "destinationAccountId",
    "configurationVersion",
    "checkoutKey",
    "amountMinor",
    "transferAmountMinor",
    "settlementHold"
  ],
  "properties": {
    "version": {
      "const": 1
    },
    "amountMinor": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "transferAmountMinor": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "settlementHold": {
      "type": [
        "boolean",
        "null"
      ]
    },
    "purpose": {
      "enum": [
        "formFee",
        "eventAdmission"
      ]
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "selection": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "route",
        "mode",
        "currency",
        "merchantCountry"
      ],
      "properties": {
        "route": {
          "enum": [
            "razorpayRoute",
            "razorpayOAuth",
            "stripeConnectDirect",
            "stripeConnectDestination"
          ]
        },
        "mode": {
          "enum": [
            "test",
            "live"
          ]
        },
        "currency": {
          "type": "string",
          "pattern": "^[A-Z]{3}$"
        },
        "merchantCountry": {
          "type": "string",
          "pattern": "^[A-Z]{2}$"
        }
      }
    },
    "policySource": {
      "enum": [
        "app",
        "organizer",
        "legacy"
      ]
    },
    "appRevision": {
      "type": "integer",
      "minimum": 0
    },
    "organizerRevision": {
      "type": "integer",
      "minimum": 0
    },
    "bindingId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "merchantAccountId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160
    },
    "destinationAccountId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 160
    },
    "configurationVersion": {
      "type": "string",
      "minLength": 1,
      "maxLength": 512
    },
    "checkoutKey": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 256
    }
  },
  "title": "PaymentRoutingSnapshot"
} as const;
