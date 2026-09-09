/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceSmsDispatchDocumentSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "attemptId",
    "messageId",
    "senderId",
    "bindingRevision",
    "configHash",
    "permissionId",
    "permissionRevision",
    "recipientEndpointId",
    "payloadHash",
    "templateId",
    "templateRevision",
    "quoteRevision",
    "grantId",
    "encoding",
    "segments",
    "maxCostMicros",
    "budgetIds",
    "createdAt",
    "reportTokenHash",
    "senderMask"
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
    "configHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
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
    "recipientEndpointId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "payloadHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "templateId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "templateRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
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
    "encoding": {
      "type": "string",
      "enum": [
        "gsm7",
        "unicode"
      ]
    },
    "segments": {
      "type": "integer",
      "minimum": 1,
      "maximum": 6
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
    "createdAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "reportTokenHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "senderMask": {
      "type": "string",
      "pattern": "^[A-Za-z]{6}$"
    }
  },
  "title": "EventAssistanceSmsDispatchDocument",
  "x-firestore-collection": "eventAssistanceSmsDispatches",
  "x-firestore-path": "eventAssistanceSmsDispatches/{attemptId}",
  "x-document-id-field": "attemptId",
  "x-owner": "trusted event-assistance SMS worker"
} as const;
