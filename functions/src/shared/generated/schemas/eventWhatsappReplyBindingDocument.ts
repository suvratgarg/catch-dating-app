/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventWhatsappReplyBindingDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_assistance_whatsapp_reply_bindings.schema.json",
  "title": "EventWhatsappReplyBindingDocument",
  "description": "Private immutable choice mapping committed with one live outbox dispatch claim. Native IDs provide correlation, never bearer authentication. A signed queued reply must match the original sender, recipient and confirmed provider message before the shared guest-action transaction can apply its stored choice.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventAssistanceWhatsappReplyBindings",
  "x-firestore-path": "eventAssistanceWhatsappReplyBindings/{attemptId}",
  "x-document-id-field": "attemptId",
  "x-owner": "trusted event-assistance WhatsApp dispatch and reply boundary",
  "required": [
    "schemaVersion",
    "attemptId",
    "messageId",
    "context",
    "guestId",
    "attendeeId",
    "episodeId",
    "attendeeGeneration",
    "guestRevision",
    "attemptScopeHash",
    "senderId",
    "bindingRevision",
    "providerAccountId",
    "providerPhoneNumberId",
    "recipientEndpointId",
    "endpointHash",
    "replyKind",
    "choices",
    "createdAt",
    "expiresAt",
    "intentHash"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "attemptId": {
      "type": "string",
      "pattern": "^attempt:[a-f0-9]{64}$"
    },
    "messageId": {
      "type": "string",
      "pattern": "^outbox:[a-f0-9]{64}$"
    },
    "context": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "mode",
        "eventId",
        "organizerId"
      ],
      "properties": {
        "mode": {
          "type": "string",
          "const": "live"
        },
        "eventId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "organizerId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 2000
        }
      }
    },
    "guestId": {
      "type": "string",
      "pattern": "^guest:[a-f0-9]{64}$"
    },
    "attendeeId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "episodeId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "attendeeGeneration": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "guestRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "attemptScopeHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
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
      "pattern": "^[0-9]{1,32}$"
    },
    "providerPhoneNumberId": {
      "type": "string",
      "pattern": "^[0-9]{1,32}$"
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
    "replyKind": {
      "type": "string",
      "enum": [
        "templateQuickReply",
        "replyButton",
        "listReply"
      ]
    },
    "choices": {
      "type": "array",
      "minItems": 1,
      "maxItems": 20,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "nativeId",
          "choiceId"
        ],
        "properties": {
          "nativeId": {
            "type": "string",
            "pattern": "^ce-wa1\\.[a-f0-9]{64}\\.([0-9]|1[0-9])$"
          },
          "choiceId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          }
        }
      }
    },
    "createdAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "expiresAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "intentHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    }
  }
} as const;
