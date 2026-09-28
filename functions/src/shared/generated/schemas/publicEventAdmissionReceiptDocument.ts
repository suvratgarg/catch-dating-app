/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const publicEventAdmissionReceiptDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/public_event_admission_receipts.schema.json",
  "title": "PublicEventAdmissionReceiptDocument",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "eventId",
    "recipientUid",
    "attendeeId",
    "canonicalSeatKey",
    "identityRevision",
    "migrationRevision",
    "registrationRevision",
    "amountPaise",
    "currency",
    "routing",
    "paymentId",
    "providerOrderId",
    "providerPaymentId",
    "admittedAtMillis",
    "resultingLedgerRevision"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "recipientUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "attendeeId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "canonicalSeatKey": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "identityRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "migrationRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "registrationRevision": {
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
    "routing": {
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
      }
    },
    "paymentId": {
      "type": "string",
      "pattern": "^pp_[a-f0-9]{32}$"
    },
    "providerOrderId": {
      "type": "string",
      "pattern": "^order_[A-Za-z0-9]+$"
    },
    "providerPaymentId": {
      "type": "string",
      "pattern": "^pay_[A-Za-z0-9]+$"
    },
    "admittedAtMillis": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "resultingLedgerRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    }
  },
  "x-firestore-collection": "publicEventAdmissionReceipts",
  "x-firestore-path": "publicEventAdmissionReceipts/{receiptId}",
  "x-document-id-field": "receiptId",
  "x-owner": "public event checkout admission service"
} as const;
