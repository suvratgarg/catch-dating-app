/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerFormPaymentDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_form_payments.schema.json",
  "title": "OrganizerFormPaymentDocument",
  "description": "Durable form fee ledger. Frozen answers remain in the revision-bound response draft; payment is separate from application review and event admission.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "formId",
    "versionId",
    "draftId",
    "respondentUid",
    "connectionId",
    "accountId",
    "mode",
    "draftRevision",
    "answersHash",
    "identity",
    "amountPaise",
    "currency",
    "description",
    "refundPolicy",
    "receipt",
    "status",
    "providerOrderId",
    "providerPaymentId",
    "providerRefundId",
    "refundedAmountPaise",
    "responseId",
    "reservationReleased",
    "leaseUntil",
    "createdAt",
    "updatedAt",
    "checkoutExpiresAt",
    "capturedAt",
    "submittedAt",
    "lastErrorCode"
  ],
  "properties": {
    "organizerId": {
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
    "draftId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "respondentUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "connectionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "accountId": {
      "type": "string",
      "pattern": "^acc_[A-Za-z0-9]+$"
    },
    "mode": {
      "enum": [
        "test",
        "live"
      ],
      "type": "string"
    },
    "draftRevision": {
      "type": "integer",
      "minimum": 1
    },
    "answersHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "identity": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "displayName",
        "email",
        "phoneE164",
        "searchName",
        "origin"
      ],
      "properties": {
        "displayName": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 160
        },
        "email": {
          "type": [
            "string",
            "null"
          ],
          "format": "email",
          "maxLength": 320
        },
        "phoneE164": {
          "type": [
            "string",
            "null"
          ],
          "pattern": "^\\+[1-9][0-9]{7,14}$"
        },
        "searchName": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 160
        },
        "origin": {
          "type": "string",
          "enum": [
            "anonymous",
            "respondentGranted",
            "organizerAcquired"
          ]
        }
      }
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
    "refundPolicy": {
      "type": "string",
      "minLength": 1,
      "maxLength": 1000
    },
    "receipt": {
      "type": "string",
      "pattern": "^cfp_[a-f0-9]{32}$"
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
    "providerOrderId": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^order_[A-Za-z0-9]+$"
    },
    "providerPaymentId": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^pay_[A-Za-z0-9]+$"
    },
    "providerRefundId": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^rfnd_[A-Za-z0-9]+$"
    },
    "refundedAmountPaise": {
      "type": "integer",
      "minimum": 0,
      "maximum": 10000000
    },
    "responseId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    },
    "reservationReleased": {
      "type": "boolean"
    },
    "leaseUntil": {
      "anyOf": [
        {
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
          }
        },
        {
          "type": "null"
        }
      ]
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
      }
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
      }
    },
    "checkoutExpiresAt": {
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
      }
    },
    "capturedAt": {
      "anyOf": [
        {
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
          }
        },
        {
          "type": "null"
        }
      ]
    },
    "submittedAt": {
      "anyOf": [
        {
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
          }
        },
        {
          "type": "null"
        }
      ]
    },
    "lastErrorCode": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 80
    }
  },
  "x-firestore-collection": "organizerFormPayments",
  "x-firestore-path": "organizerFormPayments/{paymentId}",
  "x-document-id-field": "paymentId",
  "x-owner": "organizer form payment server operations"
} as const;
