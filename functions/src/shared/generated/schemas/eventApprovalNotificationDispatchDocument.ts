/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventApprovalNotificationDispatchDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_approval_notification_dispatches.schema.json",
  "title": "EventApprovalNotificationDispatchDocument",
  "description": "Private immutable approval WhatsApp dispatch correlation, created atomically with its shared outbox claim.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventApprovalNotificationDispatches",
  "x-firestore-path": "eventApprovalNotificationDispatches/{attemptId}",
  "x-document-id-field": "attemptId",
  "x-owner": "trusted approval notification delivery worker",
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
    "recipientEndpointId",
    "endpointHash",
    "templateDocumentId",
    "templateHash",
    "payloadHash",
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
      "pattern": "^[A-Za-z0-9][a-zA-Z0-9._:-]*$"
    },
    "context": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "mode",
        "applicationId",
        "organizerId",
        "eventId",
        "uid",
        "sourceResponseId",
        "approvedAtMillis",
        "approvalRevision"
      ],
      "properties": {
        "mode": {
          "type": "string",
          "const": "live"
        },
        "applicationId": {
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
        "eventId": {
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
        "sourceResponseId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "approvedAtMillis": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "approvalRevision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        }
      }
    },
    "senderId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$",
      "description": "organizerSenderConnections document id that owned the send."
    },
    "bindingRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "providerAccountId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[0-9]{1,32}$"
    },
    "providerPhoneNumberId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[0-9]{1,32}$"
    },
    "senderHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$",
      "description": "Content hash of the sender connection snapshot authorized at claim."
    },
    "recipientEndpointId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
    },
    "endpointHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$",
      "description": "Hash of the E.164 destination; the raw number never appears here."
    },
    "templateDocumentId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
    },
    "templateHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "payloadHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$",
      "description": "Content hash of the rendered template + variables; the status callback must carry the matching correlation."
    },
    "createdAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    }
  }
} as const;
