/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventRcsCallbackReceiptDocumentSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "callbackId",
    "callbackHash",
    "processedAt",
    "outcome"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "callbackId": {
      "type": "string",
      "pattern": "^rcs-event:[a-f0-9]{64}$"
    },
    "callbackHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "processedAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "outcome": {
      "oneOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "messageId",
            "attemptId",
            "disposition"
          ],
          "properties": {
            "kind": {
              "const": "delivery"
            },
            "messageId": {
              "type": "string",
              "pattern": "^outbox:[a-f0-9]{64}$"
            },
            "attemptId": {
              "type": "string",
              "pattern": "^attempt:[a-f0-9]{64}$"
            },
            "disposition": {
              "type": "string",
              "enum": [
                "applied",
                "duplicateOrOlder",
                "conflictingEvidence"
              ]
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "messageId",
            "attemptId",
            "result"
          ],
          "properties": {
            "kind": {
              "const": "reply"
            },
            "messageId": {
              "type": "string",
              "pattern": "^outbox:[a-f0-9]{64}$"
            },
            "attemptId": {
              "type": "string",
              "pattern": "^attempt:[a-f0-9]{64}$"
            },
            "result": {
              "type": "string",
              "enum": [
                "accepted",
                "replayed"
              ]
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "reason"
          ],
          "properties": {
            "kind": {
              "const": "ignored"
            },
            "reason": {
              "type": "string",
              "enum": [
                "subscription",
                "unstructured",
                "guestPage",
                "unknownSuggestion",
                "unconfirmedRevocation",
                "unrelatedMessage"
              ]
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "reason"
          ],
          "properties": {
            "kind": {
              "const": "rejected"
            },
            "reason": {
              "type": "string",
              "enum": [
                "unavailable",
                "scopeMismatch",
                "staleIntent",
                "invalidChoice",
                "expired",
                "alreadyResponded",
                "noLongerNeeded",
                "factsStale",
                "guestStateChanged"
              ]
            }
          }
        }
      ]
    }
  },
  "title": "EventRcsCallbackReceiptDocument",
  "x-firestore-collection": "eventAssistanceRcsCallbackReceipts",
  "x-firestore-path": "eventAssistanceRcsCallbackReceipts/{callbackId}",
  "x-document-id-field": "callbackId",
  "x-owner": "event-service RCS callback consumer"
} as const;
