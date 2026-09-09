/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventWhatsappDispatchDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_whatsapp_dispatches.schema.json",
  "title": "EventWhatsappDispatchDocument",
  "description": "Immutable debit and material identity committed with one outbox dispatch claim. No credentials, body, guest secret or recipient phone.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "attemptId",
    "messageId",
    "context",
    "senderId",
    "bindingRevision",
    "providerAccountId",
    "providerPhoneNumberId",
    "senderHash",
    "policyHash",
    "policyRevision",
    "permissionId",
    "permissionRevision",
    "permissionHash",
    "recipientEndpointId",
    "endpointHash",
    "templateDocumentId",
    "templateHash",
    "payloadHash",
    "quoteRevision",
    "grantId",
    "currency",
    "maxCostMicros",
    "budgetIds",
    "replyBindingId",
    "stopRecordHash",
    "createdAt"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "attemptId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "messageId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "context": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "mode",
        "organizerId",
        "eventId"
      ],
      "properties": {
        "mode": {
          "type": "string",
          "const": "live"
        },
        "organizerId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "eventId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        }
      }
    },
    "senderId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "bindingRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "providerAccountId": {
      "type": "string",
      "pattern": "^[0-9]{5,40}$"
    },
    "providerPhoneNumberId": {
      "type": "string",
      "pattern": "^[0-9]{5,40}$"
    },
    "senderHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "policyHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "policyRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "permissionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "permissionRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "permissionHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "recipientEndpointId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "endpointHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "templateDocumentId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "templateHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "payloadHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "quoteRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "grantId": {
      "type": "string",
      "pattern": "^[a-f0-9]{32}$"
    },
    "currency": {
      "type": "string",
      "pattern": "^[A-Z]{3}$"
    },
    "maxCostMicros": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "budgetIds": {
      "type": "array",
      "minItems": 2,
      "maxItems": 2,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 160,
        "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
      }
    },
    "replyBindingId": {
      "anyOf": [
        {
          "type": "null"
        },
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        }
      ]
    },
    "stopRecordHash": {
      "anyOf": [
        {
          "type": "null"
        },
        {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        }
      ]
    },
    "createdAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    }
  },
  "x-firestore-collection": "eventAssistanceWhatsappDispatches",
  "x-firestore-path": "eventAssistanceWhatsappDispatches/{attemptId}",
  "x-document-id-field": "attemptId",
  "x-owner": "trusted WhatsApp event service workers"
} as const;
