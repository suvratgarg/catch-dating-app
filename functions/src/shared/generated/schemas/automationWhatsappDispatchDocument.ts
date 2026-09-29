/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const automationWhatsappDispatchDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/automation_whatsapp_dispatches.schema.json",
  "title": "AutomationWhatsappDispatchDocument",
  "description": "Private claim-time binding between one automation delivery attempt and the exact Meta WhatsApp submission. Webhook status callbacks verify against this record before a receipt can merge into the automation delivery outbox.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "automationWhatsappDispatches",
  "x-firestore-path": "automationWhatsappDispatches/{attemptId}",
  "x-document-id-field": "attemptId",
  "x-owner": "trusted automation delivery workers",
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
        "organizerId",
        "ruleId",
        "ruleRevision",
        "actionId",
        "eventKind",
        "sourceId",
        "occurredAtMillis",
        "dueAtMillis",
        "contactId",
        "recipeCampaignId",
        "recipeRevision"
      ],
      "properties": {
        "mode": {
          "type": "string",
          "const": "live"
        },
        "organizerId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 2000
        },
        "ruleId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "ruleRevision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 1000000,
          "description": "Approved rule revision the intent was authorized under. Claim re-reads the live rule; a changed revision stops the intent as superseded."
        },
        "actionId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "eventKind": {
          "type": "string",
          "enum": [
            "submitted",
            "withdrawn",
            "applicationAccepted",
            "eventAttended"
          ]
        },
        "sourceId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "occurredAtMillis": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991,
          "description": "Source-event occurrence time; part of the durable occurrence identity alongside ruleId/actionId/eventKind/sourceId."
        },
        "dueAtMillis": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991,
          "description": "The business delay horizon the automation engine computed (max(occurredAt, eventEndAt) + delayMinutes). Claim re-derives it from the live event and rule."
        },
        "contactId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$",
          "description": "Contact identity resolved from the source event at handoff. Claim re-derives the current identity from the live source event, so a merge follows the send to the surviving contact."
        },
        "recipeCampaignId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$",
          "description": "organizerCampaigns document id of the recipe the action pinned."
        },
        "recipeRevision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 1000000
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
