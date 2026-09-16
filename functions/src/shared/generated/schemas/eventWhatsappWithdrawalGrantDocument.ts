/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventWhatsappWithdrawalGrantDocumentSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "linkId",
    "permissionId",
    "context",
    "attendeeId",
    "attendeeGeneration",
    "subjectUid",
    "senderId",
    "recipientEndpointId",
    "guestGrantHash",
    "permissionRevisionAtIssue",
    "issuedAt",
    "expiresAt",
    "providerAccountId",
    "providerPhoneNumberId"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "linkId": {
      "type": "string",
      "pattern": "^[a-f0-9]{32}$"
    },
    "permissionId": {
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
    "subjectUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "senderId": {
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
    "guestGrantHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "permissionRevisionAtIssue": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "issuedAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "expiresAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "providerAccountId": {
      "type": "string",
      "pattern": "^[0-9]{5,40}$"
    },
    "providerPhoneNumberId": {
      "type": "string",
      "pattern": "^[0-9]{5,40}$"
    }
  },
  "title": "EventWhatsappWithdrawalGrantDocument",
  "x-firestore-collection": "eventAssistanceWhatsappWithdrawalGrants",
  "x-firestore-path": "eventAssistanceWhatsappWithdrawalGrants/{linkId}",
  "x-document-id-field": "linkId",
  "x-owner": "event-service WhatsApp dispatch and withdrawal"
} as const;
