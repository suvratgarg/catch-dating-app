/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventWhatsappConsentReceiptDocumentSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "receiptId",
    "requestHash",
    "context",
    "attendeeId",
    "attendeeGeneration",
    "senderId",
    "routeId",
    "actorUid",
    "recipientEndpointId",
    "decision",
    "copyVersion",
    "copyHash",
    "appliedRevision",
    "createdAt",
    "permissionHash",
    "source",
    "linkId",
    "senderHash"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "receiptId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "requestHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
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
    "attendeeId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "attendeeGeneration": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "senderId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "routeId": {
      "type": "string",
      "const": "organizerEventWhatsapp"
    },
    "actorUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "recipientEndpointId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "decision": {
      "type": "string",
      "enum": [
        "grant",
        "revoke"
      ]
    },
    "copyVersion": {
      "anyOf": [
        {
          "type": "null"
        },
        {
          "type": "string",
          "const": "catch-event-service-whatsapp-v1"
        }
      ]
    },
    "copyHash": {
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
    "appliedRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "createdAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "permissionHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "source": {
      "type": "string",
      "const": "verifiedParticipant"
    },
    "linkId": {
      "type": "null"
    },
    "senderHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    }
  },
  "title": "EventWhatsappConsentReceiptDocument",
  "x-firestore-collection": "eventAssistanceWhatsappConsentReceipts",
  "x-firestore-path": "eventAssistanceWhatsappConsentReceipts/{receiptId}",
  "x-document-id-field": "receiptId",
  "x-owner": "verified participant event-service preferences"
} as const;
