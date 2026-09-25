/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventOfferPaymentSnapshotSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/embedded/event_offer_payment_snapshot.schema.json",
  "title": "EventOfferPaymentSnapshot",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventPaymentRevision",
    "eventPaymentHash",
    "expectedAmountMinor",
    "currency",
    "reusablePaymentPageUrl",
    "paymentInstructions",
    "messageTemplate",
    "expiresAtMillis",
    "collectionMode",
    "personalPaymentLink"
  ],
  "properties": {
    "eventPaymentRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000000000
    },
    "eventPaymentHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "expectedAmountMinor": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100000000
    },
    "currency": {
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
    "reusablePaymentPageUrl": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 2048,
          "format": "uri",
          "pattern": "^https://"
        },
        {
          "type": "null"
        }
      ]
    },
    "paymentInstructions": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 1000
        },
        {
          "type": "null"
        }
      ]
    },
    "messageTemplate": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 1000
        },
        {
          "type": "null"
        }
      ]
    },
    "expiresAtMillis": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "collectionMode": {
      "anyOf": [
        {
          "type": "string",
          "enum": [
            "manualInstructions",
            "reusablePage",
            "personalRequest",
            "catchCheckout"
          ]
        },
        {
          "type": "null"
        }
      ]
    },
    "personalPaymentLink": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 2048,
          "format": "uri",
          "pattern": "^https://"
        },
        {
          "type": "null"
        }
      ]
    }
  }
} as const;
