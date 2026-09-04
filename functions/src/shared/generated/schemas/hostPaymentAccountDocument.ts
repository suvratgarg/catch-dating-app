/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const hostPaymentAccountDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/host_payment_accounts.schema.json",
  "title": "HostPaymentAccountDocument",
  "description": "Server-owned payout-provider account state. New documents use hostPaymentAccounts/{uid}_{provider}; legacy Stripe documents at {uid} remain readable during migration.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "hostPaymentAccounts",
  "x-firestore-path": "hostPaymentAccounts/{accountId}",
  "x-document-id-field": "id",
  "x-owner": "Stripe Connect and Razorpay Route onboarding, refresh, and webhook callables",
  "required": [
    "userId",
    "provider",
    "country",
    "defaultCurrency",
    "providerAccountId",
    "stripeAccountId",
    "razorpayAccountId",
    "chargesEnabled",
    "payoutsEnabled",
    "detailsSubmitted",
    "onboardingStatus",
    "requirementsCurrentlyDue",
    "requirementsPastDue",
    "requirementsPendingVerification",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "userId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "provider": {
      "type": "string",
      "enum": [
        "razorpay",
        "stripe"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "country": {
      "type": "string",
      "minLength": 2,
      "maxLength": 2,
      "x-catch-ownership": "callable-owned"
    },
    "defaultCurrency": {
      "type": "string",
      "minLength": 3,
      "maxLength": 3,
      "x-catch-ownership": "callable-owned"
    },
    "providerAccountId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "x-catch-ownership": "callable-owned"
    },
    "stripeAccountId": {
      "type": "string",
      "maxLength": 120,
      "x-catch-ownership": "callable-owned"
    },
    "razorpayAccountId": {
      "type": "string",
      "maxLength": 120,
      "x-catch-ownership": "callable-owned"
    },
    "razorpayProductId": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 120,
      "x-catch-ownership": "callable-owned"
    },
    "chargesEnabled": {
      "type": "boolean",
      "x-catch-ownership": "callable-owned"
    },
    "payoutsEnabled": {
      "type": "boolean",
      "x-catch-ownership": "callable-owned"
    },
    "detailsSubmitted": {
      "type": "boolean",
      "x-catch-ownership": "callable-owned"
    },
    "onboardingStatus": {
      "type": "string",
      "enum": [
        "notStarted",
        "pending",
        "complete",
        "restricted"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "disabledReason": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 240,
      "x-catch-ownership": "callable-owned"
    },
    "requirementsCurrentlyDue": {
      "type": "array",
      "maxItems": 80,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 160
      },
      "x-catch-ownership": "callable-owned"
    },
    "requirementsPastDue": {
      "type": "array",
      "maxItems": 80,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 160
      },
      "x-catch-ownership": "callable-owned"
    },
    "requirementsPendingVerification": {
      "type": "array",
      "maxItems": 80,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 160
      },
      "x-catch-ownership": "callable-owned"
    },
    "lastStripeEventId": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "createdAt": {
      "type": "object",
      "description": "Serialized Firestore Timestamp fixture shape.",
      "x-firestore-type": "timestamp",
      "additionalProperties": false,
      "required": [
        "_seconds",
        "_nanoseconds"
      ],
      "properties": {
        "_seconds": {
          "type": "integer"
        },
        "_nanoseconds": {
          "type": "integer",
          "minimum": 0,
          "maximum": 999999999
        }
      },
      "x-catch-ownership": "callable-owned"
    },
    "updatedAt": {
      "type": "object",
      "description": "Serialized Firestore Timestamp fixture shape.",
      "x-firestore-type": "timestamp",
      "additionalProperties": false,
      "required": [
        "_seconds",
        "_nanoseconds"
      ],
      "properties": {
        "_seconds": {
          "type": "integer"
        },
        "_nanoseconds": {
          "type": "integer",
          "minimum": 0,
          "maximum": 999999999
        }
      },
      "x-catch-ownership": "callable-owned"
    }
  }
} as const;
