/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceRcsCallbackIdentityDocumentSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "receiptKey",
    "primaryCallbackId",
    "firstStoredAt",
    "conflictedAt"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "receiptKey": {
      "type": "string",
      "pattern": "^rcs-callback:[a-f0-9]{64}$"
    },
    "primaryCallbackId": {
      "type": "string",
      "pattern": "^rcs-event:[a-f0-9]{64}$"
    },
    "firstStoredAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "conflictedAt": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 0,
      "maximum": 9007199254740991
    }
  },
  "title": "EventAssistanceRcsCallbackIdentityDocument",
  "x-firestore-collection": "eventAssistanceRcsCallbackIdentities",
  "x-firestore-path": "eventAssistanceRcsCallbackIdentities/{receiptKey}",
  "x-document-id-field": "receiptKey",
  "x-owner": "event-assistance authenticated RCS ingress"
} as const;
