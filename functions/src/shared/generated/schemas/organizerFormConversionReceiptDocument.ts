/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerFormConversionReceiptDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_form_conversion_receipts.schema.json",
  "title": "OrganizerFormConversionReceiptDocument",
  "description": "Idempotent reviewed downstream conversion and safe-undo boundary.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "formId",
    "responseId",
    "kind",
    "requestId",
    "actorUid",
    "status",
    "fields",
    "resultId",
    "undoStatus",
    "createdAt",
    "updatedAt",
    "completedAt"
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
    "responseId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "kind": {
      "type": "string",
      "enum": [
        "crmContact",
        "application",
        "eventAttendeeProposal",
        "followUp"
      ]
    },
    "requestId": {
      "type": "string",
      "minLength": 8,
      "maxLength": 128
    },
    "actorUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "status": {
      "type": "string",
      "enum": [
        "pending",
        "completed",
        "failed"
      ]
    },
    "fields": {
      "type": "array",
      "maxItems": 100,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "destinationField",
          "label",
          "value",
          "origin",
          "conflict"
        ],
        "properties": {
          "destinationField": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "label": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160
          },
          "value": {
            "type": [
              "string",
              "number",
              "boolean",
              "null"
            ],
            "maxLength": 1000
          },
          "origin": {
            "type": "string",
            "enum": [
              "verifiedIdentity",
              "formAnswer",
              "hostOverride"
            ]
          },
          "conflict": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 500
          }
        }
      }
    },
    "resultId": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 200
    },
    "undoStatus": {
      "type": "string",
      "enum": [
        "notAvailable",
        "available",
        "used",
        "expired"
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
    "completedAt": {
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
    }
  },
  "x-firestore-collection": "organizerFormConversionReceipts",
  "x-firestore-path": "organizerFormConversionReceipts/{receiptId}",
  "x-document-id-field": "receiptId",
  "x-owner": "organizer form reviewed conversion"
} as const;
