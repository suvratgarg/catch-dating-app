/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const paymentDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/payments.schema.json",
  "title": "PaymentDocument",
  "description": "Canonical payment record stored at payments/{paymentId}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "payments",
  "x-firestore-path": "payments/{paymentId}",
  "x-document-id-field": "id",
  "x-owner": "payments callables",
  "x-internal-demo-fields": [
    "synthetic",
    "seedPrefix",
    "scenario",
    "demoOps",
    "demoOpsId",
    "demoOpsCommand"
  ],
  "required": [
    "userId",
    "orderId",
    "paymentId",
    "eventId",
    "amount",
    "currency",
    "status",
    "signUpFailed",
    "createdAt"
  ],
  "properties": {
    "userId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "orderId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240,
      "x-catch-ownership": "callable-owned"
    },
    "paymentId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240,
      "x-catch-ownership": "callable-owned"
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "amount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100000000,
      "x-catch-ownership": "callable-owned"
    },
    "amountMinor": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100000000,
      "x-catch-ownership": "callable-owned"
    },
    "currency": {
      "type": "string",
      "minLength": 3,
      "maxLength": 3,
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
    "status": {
      "type": "string",
      "enum": [
        "pending",
        "completed",
        "failed",
        "refunded",
        "refundFailed"
      ],
      "description": "refundFailed marks a booking that failed AND whose automatic refund could not be issued, so the charge is stuck and needs manual reconciliation.",
      "x-catch-ownership": "callable-owned"
    },
    "providerPaymentId": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 240,
      "x-catch-ownership": "callable-owned"
    },
    "checkoutSessionId": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 240,
      "x-catch-ownership": "callable-owned"
    },
    "hostUserId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "stripeAccountId": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 120,
      "x-catch-ownership": "callable-owned"
    },
    "applicationFeeAmount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100000000,
      "x-catch-ownership": "callable-owned"
    },
    "inviteLinkId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180,
      "description": "Named host invite link attributed to this payment, when present.",
      "x-catch-ownership": "callable-owned"
    },
    "inviteSource": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 80,
      "description": "Host-facing invite source copied from eventInviteLinks.",
      "x-catch-ownership": "callable-owned"
    },
    "crossPathsPairHoldId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180,
      "description": "Pair hold consumed by this booking, when present.",
      "x-catch-ownership": "callable-owned"
    },
    "signUpFailed": {
      "type": "boolean",
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
    "completedAt": {
      "type": "object",
      "description": "Authoritative completion time for a successful payment. Older completed records may omit it and fall back to createdAt.",
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
    "synthetic": {
      "type": "boolean",
      "description": "Internal demo seed marker used for cleanup and diagnostics."
    },
    "seedPrefix": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "description": "Internal demo seed prefix used for cleanup and diagnostics."
    },
    "scenario": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "description": "Internal demo seed scenario name used for cleanup and diagnostics."
    },
    "demoOps": {
      "type": "boolean",
      "description": "Internal demo-operations marker used for cleanup and diagnostics."
    },
    "demoOpsId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "description": "Internal demo-operations id used for cleanup and diagnostics."
    },
    "demoOpsCommand": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80,
      "description": "Internal demo-operations command name used for cleanup and diagnostics."
    }
  }
} as const;
