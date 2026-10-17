/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventApprovalNotificationReceiptDocumentSchema: Record<string, unknown> = {
  "title": "EventApprovalNotificationReceiptDocument",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "organizerId",
    "uid",
    "revision",
    "choices",
    "phoneE164",
    "email",
    "termsVersion",
    "receiptId",
    "updatedAtMillis"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "revision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "choices": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "phoneUpdates",
        "emailUpdates"
      ],
      "properties": {
        "phoneUpdates": {
          "type": "boolean"
        },
        "emailUpdates": {
          "type": "boolean"
        }
      }
    },
    "phoneE164": {
      "anyOf": [
        {
          "type": "string",
          "pattern": "^\\+[1-9][0-9]{6,14}$"
        },
        {
          "type": "null"
        }
      ]
    },
    "email": {
      "anyOf": [
        {
          "type": "string",
          "format": "email",
          "maxLength": 254
        },
        {
          "type": "null"
        }
      ]
    },
    "termsVersion": {
      "const": "event-approval-v1",
      "type": "string"
    },
    "receiptId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "updatedAtMillis": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    }
  },
  "x-firestore-collection": "eventApprovalNotificationReceipts",
  "x-firestore-path": "eventApprovalNotificationReceipts/{id}",
  "x-owner": "trusted event approval notification services"
} as const;
