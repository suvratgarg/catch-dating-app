/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventOfferManualPaymentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/embedded/event_offer_manual_payment.schema.json",
  "title": "EventOfferManualPayment",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "status",
    "evidenceReference",
    "evidenceRecordedAtMillis",
    "reviewedByUid",
    "reviewedAtMillis",
    "reviewNote",
    "bankReceiptChecked",
    "attestedAmountMinor",
    "attestedCurrency",
    "attestedEventPaymentRevision",
    "attestedEventPaymentHash"
  ],
  "properties": {
    "status": {
      "type": "string",
      "enum": [
        "none",
        "evidenceSubmitted",
        "hostAttestedReceived",
        "rejected"
      ]
    },
    "evidenceReference": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 3,
          "maxLength": 240
        },
        {
          "type": "null"
        }
      ]
    },
    "evidenceRecordedAtMillis": {
      "anyOf": [
        {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        },
        {
          "type": "null"
        }
      ]
    },
    "reviewedByUid": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "pattern": "^[A-Za-z0-9_-]{1,180}$"
        },
        {
          "type": "null"
        }
      ]
    },
    "reviewedAtMillis": {
      "anyOf": [
        {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        },
        {
          "type": "null"
        }
      ]
    },
    "reviewNote": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 3,
          "maxLength": 240
        },
        {
          "type": "null"
        }
      ]
    },
    "bankReceiptChecked": {
      "type": "boolean"
    },
    "attestedAmountMinor": {
      "anyOf": [
        {
          "type": "integer",
          "minimum": 0,
          "maximum": 100000000
        },
        {
          "type": "null"
        }
      ]
    },
    "attestedCurrency": {
      "anyOf": [
        {
          "type": "string",
          "pattern": "^[A-Z]{3}$"
        },
        {
          "type": "null"
        }
      ]
    },
    "attestedEventPaymentRevision": {
      "anyOf": [
        {
          "type": "integer",
          "minimum": 1,
          "maximum": 1000000000
        },
        {
          "type": "null"
        }
      ]
    },
    "attestedEventPaymentHash": {
      "anyOf": [
        {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        {
          "type": "null"
        }
      ]
    }
  }
} as const;
