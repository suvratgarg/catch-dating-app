/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceRcsConfigSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "senderId",
    "revision",
    "provider",
    "senderIdentity",
    "agentId",
    "region",
    "status",
    "credentialVersion",
    "recipientPrefixes",
    "activation",
    "quote",
    "maxQueueSeconds",
    "allowedPurposes",
    "displayName"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "senderId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "provider": {
      "type": "string",
      "const": "googleRbm"
    },
    "senderIdentity": {
      "type": "string",
      "const": "catchPlatform"
    },
    "agentId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 512,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._@-]*$"
    },
    "region": {
      "type": "string",
      "enum": [
        "asia",
        "europe",
        "us"
      ]
    },
    "status": {
      "type": "string",
      "enum": [
        "inactive",
        "ready",
        "paused"
      ]
    },
    "credentialVersion": {
      "type": "string",
      "maxLength": 240,
      "pattern": "^projects/[A-Za-z0-9-]+/secrets/[A-Za-z0-9_-]+/versions/[1-9][0-9]*$"
    },
    "recipientPrefixes": {
      "type": "array",
      "minItems": 1,
      "maxItems": 20,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "pattern": "^\\+[1-9][0-9]{0,3}$"
      }
    },
    "activation": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "approvalId",
        "approvedAt",
        "validUntil"
      ],
      "properties": {
        "approvalId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "approvedAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "validUntil": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        }
      }
    },
    "quote": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "revision",
        "currency",
        "maxMicrosPerMessage",
        "validUntil"
      ],
      "properties": {
        "revision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        },
        "currency": {
          "type": "string",
          "pattern": "^[A-Z]{3}$"
        },
        "maxMicrosPerMessage": {
          "type": "integer",
          "minimum": 1,
          "maximum": 1000000000
        },
        "validUntil": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        }
      }
    },
    "maxQueueSeconds": {
      "type": "integer",
      "minimum": 10,
      "maximum": 3600
    },
    "allowedPurposes": {
      "type": "array",
      "minItems": 1,
      "maxItems": 9,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "enum": [
          "joiningUpdate",
          "joiningInstructions",
          "planChanged",
          "guestRequirement",
          "assignmentChanged",
          "participationCheck",
          "eventCancelled",
          "eventFinished",
          "followUp"
        ]
      }
    },
    "displayName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160
    }
  },
  "title": "EventAssistanceRcsConfig"
} as const;
