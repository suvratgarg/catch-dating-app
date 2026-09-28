/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesDemoSessionsDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/sales_demo_sessions.schema.json",
  "title": "SalesDemoSessionDocument",
  "description": "Isolated synthetic Forms practice state; no production guest, message, payment or membership references.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "classification",
    "sessionId",
    "invitationId",
    "blueprintId",
    "blueprintRevision",
    "actorUid",
    "createdAt",
    "expiresAt",
    "status",
    "allowedActions",
    "revision",
    "actionCount",
    "step",
    "application",
    "reply",
    "guest",
    "assistanceRequested"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "classification": {
      "const": "sales_private"
    },
    "sessionId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "invitationId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "blueprintId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "blueprintRevision": {
      "type": "integer",
      "minimum": 1
    },
    "actorUid": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    },
    "createdAt": {
      "type": "string",
      "format": "date-time"
    },
    "expiresAt": {
      "type": "string",
      "format": "date-time"
    },
    "status": {
      "enum": [
        "active",
        "completed"
      ]
    },
    "allowedActions": {
      "type": "array",
      "minItems": 1,
      "maxItems": 4,
      "uniqueItems": true,
      "items": {
        "enum": [
          "reviewApplication",
          "prepareReply",
          "admitGuest",
          "requestAssistance"
        ]
      }
    },
    "revision": {
      "type": "integer",
      "minimum": 1
    },
    "actionCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 20
    },
    "step": {
      "enum": [
        "application",
        "reply",
        "admission",
        "complete"
      ]
    },
    "application": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "applicantName",
        "request",
        "review"
      ],
      "properties": {
        "applicantName": {
          "const": "Sample Applicant"
        },
        "request": {
          "const": "Sample event application"
        },
        "review": {
          "enum": [
            "pending",
            "approved",
            "needs_info"
          ]
        }
      }
    },
    "reply": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "status",
        "template"
      ],
      "properties": {
        "status": {
          "enum": [
            "none",
            "prepared"
          ]
        },
        "template": {
          "enum": [
            "none",
            "welcome",
            "clarify"
          ]
        }
      }
    },
    "guest": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "status",
        "displayName"
      ],
      "properties": {
        "status": {
          "enum": [
            "not_admitted",
            "admitted"
          ]
        },
        "displayName": {
          "const": "Sample Applicant"
        }
      }
    },
    "assistanceRequested": {
      "type": "boolean"
    }
  },
  "definitions": {
    "id": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{3,128}$"
    }
  },
  "x-firestore-collection": "salesDemoSessions",
  "x-firestore-path": "salesDemoSessions/{sessionId}",
  "x-document-id-field": "sessionId",
  "x-owner": "sales demo trial callable and bounded expiry worker"
} as const;
