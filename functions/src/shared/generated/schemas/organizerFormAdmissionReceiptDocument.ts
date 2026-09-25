/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerFormAdmissionReceiptDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_form_admission_receipts.schema.json",
  "title": "OrganizerFormAdmissionReceiptDocument",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "eventId",
    "responseId",
    "contactId",
    "offerId",
    "expectedOfferRevision",
    "expectedOfferGeneration",
    "expectedLedgerRevision",
    "requestId",
    "receiptId",
    "attendeeId",
    "canonicalSeatKey",
    "requestHash",
    "resultingLedgerRevision",
    "admittedAtMillis",
    "seatAlreadyOccupied",
    "actorUid",
    "paymentSnapshot",
    "manualPayment"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9_-]{1,180}$"
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9_-]{1,180}$"
    },
    "responseId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9_-]{1,180}$"
    },
    "contactId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9_-]{1,180}$"
    },
    "offerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9_-]{1,180}$"
    },
    "expectedOfferRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "expectedOfferGeneration": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "expectedLedgerRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "requestId": {
      "type": "string",
      "minLength": 8,
      "maxLength": 120,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{7,119}$"
    },
    "receiptId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9_-]{1,180}$"
    },
    "attendeeId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9_-]{1,180}$"
    },
    "canonicalSeatKey": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9_-]{1,180}$"
    },
    "requestHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "resultingLedgerRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "admittedAtMillis": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "seatAlreadyOccupied": {
      "type": "boolean"
    },
    "actorUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9_-]{1,180}$"
    },
    "paymentSnapshot": {
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
    },
    "manualPayment": {
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
    }
  }
} as const;
