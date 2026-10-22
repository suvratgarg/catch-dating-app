/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const hostOperatorAlertDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/host_operator_alerts.schema.json",
  "title": "HostOperatorAlertDocument",
  "description": "Private operator notice receipt keyed by the original accepted Host lead. No applicant details or contact data.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "hostOperatorAlerts",
  "x-firestore-path": "hostOperatorAlerts/{eventId}",
  "x-document-id-field": "eventId",
  "x-owner": "onHostApplicationAccepted and dispatchHostApplicationAlerts",
  "required": [
    "schemaVersion",
    "classification",
    "eventId",
    "intentId",
    "acceptedAt",
    "status",
    "attempts",
    "attemptId",
    "providerMessageId"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "classification": {
      "const": "sales_private"
    },
    "eventId": {
      "type": "string",
      "pattern": "^host_lead_[0-9]{13}_[a-f0-9]{8}(-[a-f0-9]{4}){3}-[a-f0-9]{12}$"
    },
    "intentId": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "acceptedAt": {
      "type": "integer",
      "minimum": 1
    },
    "status": {
      "enum": [
        "pending",
        "sending",
        "accepted",
        "failed",
        "unknown",
        "stopped"
      ]
    },
    "attempts": {
      "type": "integer",
      "minimum": 0,
      "maximum": 5
    },
    "attemptId": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^[a-f0-9-]{36}$"
    },
    "providerMessageId": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^[A-Za-z0-9_-]{1,128}$"
    },
    "nextAttemptAt": {
      "type": "integer",
      "minimum": 1
    }
  },
  "allOf": [
    {
      "if": {
        "properties": {
          "status": {
            "enum": [
              "pending",
              "sending"
            ]
          }
        }
      },
      "then": {
        "required": [
          "nextAttemptAt"
        ]
      },
      "else": {
        "properties": {
          "nextAttemptAt": false
        }
      }
    }
  ]
} as const;
