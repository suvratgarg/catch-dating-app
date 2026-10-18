/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventApprovalNotificationIntentSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "intentId",
    "revision",
    "context",
    "createdAt",
    "expiresAt",
    "lane",
    "permittedRoutes",
    "deliveryPolicy"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "intentId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "revision": {
      "type": "integer",
      "const": 1
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
    "lane": {
      "type": "string",
      "enum": [
        "phone",
        "email"
      ]
    },
    "permittedRoutes": {
      "type": "array",
      "minItems": 1,
      "maxItems": 2,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "enum": [
          "approvalWhatsapp",
          "approvalSms",
          "approvalEmail"
        ]
      }
    },
    "deliveryPolicy": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "maxAttempts",
        "maxAttemptsPerRoute",
        "minimumRetrySeconds"
      ],
      "properties": {
        "maxAttempts": {
          "type": "integer",
          "const": 3
        },
        "maxAttemptsPerRoute": {
          "type": "integer",
          "const": 1
        },
        "minimumRetrySeconds": {
          "type": "integer",
          "const": 60
        }
      }
    }
  },
  "title": "EventApprovalNotificationIntent"
} as const;
