/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const campaignDeliveryMessageIntentSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "intentId",
    "revision",
    "context",
    "campaignId",
    "recipient",
    "workflow",
    "createdAt",
    "expiresAt",
    "permittedRoutes",
    "deliveryPolicy",
    "kind",
    "instructionRevision",
    "whatsapp"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1,
      "type": "integer"
    },
    "intentId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000000
    },
    "context": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "mode",
        "organizerId",
        "campaignId",
        "recipientId"
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
        "campaignId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "recipientId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        }
      }
    },
    "campaignId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "recipient": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "kind",
        "recipientKey"
      ],
      "properties": {
        "kind": {
          "type": "string",
          "enum": [
            "campaignRecipient"
          ]
        },
        "recipientKey": {
          "type": "string",
          "minLength": 1,
          "maxLength": 2000,
          "description": "organizerCampaignRecipients document id — the frozen per-recipient campaign row. Endpoint and consent facts resolve at claim time, never in the intent."
        }
      }
    },
    "workflow": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "kind",
        "campaignId",
        "recipientId"
      ],
      "properties": {
        "kind": {
          "type": "string",
          "const": "campaignDispatch"
        },
        "campaignId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "recipientId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
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
    "permittedRoutes": {
      "type": "array",
      "minItems": 1,
      "maxItems": 1,
      "items": {
        "type": "string",
        "enum": [
          "organizerWhatsappCampaign"
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
          "minimum": 1,
          "maximum": 6
        },
        "maxAttemptsPerRoute": {
          "type": "integer",
          "minimum": 1,
          "maximum": 6
        },
        "minimumRetrySeconds": {
          "type": "integer",
          "minimum": 0,
          "maximum": 86400
        }
      }
    },
    "kind": {
      "type": "string",
      "const": "campaignMessage"
    },
    "instructionRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991,
      "description": "The campaign dispatch epoch (dispatchedAt millis) this intent was issued under. Reservation authority expires when the campaign's dispatch epoch changes."
    },
    "whatsapp": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "connectionId",
        "templateId",
        "variables"
      ],
      "properties": {
        "connectionId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
        },
        "templateId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
        },
        "variables": {
          "type": "object",
          "maxProperties": 20,
          "additionalProperties": {
            "type": "string",
            "maxLength": 1000
          }
        }
      },
      "description": "Approved WhatsApp template content frozen from the campaign/recipient snapshot; sender credentials never appear here."
    }
  },
  "title": "CampaignDeliveryMessageIntent"
} as const;
