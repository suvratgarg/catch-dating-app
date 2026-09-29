/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const automationDeliveryMessageIntentSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "intentId",
    "revision",
    "context",
    "ruleId",
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
    "ruleId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][a-zA-Z0-9._:-]*$"
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
            "organizerContact"
          ]
        },
        "recipientKey": {
          "type": "string",
          "minLength": 1,
          "maxLength": 2000,
          "description": "organizerContacts document id resolved at handoff. Endpoint and consent facts resolve at claim time, never in the intent."
        }
      }
    },
    "workflow": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "kind",
        "momentId",
        "runId"
      ],
      "properties": {
        "kind": {
          "type": "string",
          "const": "automationSend"
        },
        "momentId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$",
          "description": "The rule's server-managed companion moment."
        },
        "runId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$",
          "description": "The occurrence-keyed moment run journaling this send."
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
          "organizerWhatsappAutomation"
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
      "const": "automationMessage"
    },
    "instructionRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991,
      "description": "The companion moment's revision at handoff. Reservation authority expires when the synced rule projection changes."
    },
    "whatsapp": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "connectionId",
        "templateId",
        "variables",
        "eventId",
        "inviteLinkId"
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
        },
        "eventId": {
          "anyOf": [
            {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            {
              "type": "null"
            }
          ],
          "description": "Event destination pinned by the recipe; claim re-verifies the event is still active and owned."
        },
        "inviteLinkId": {
          "anyOf": [
            {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            {
              "type": "null"
            }
          ],
          "description": "Per-occurrence invitation link minted at handoff; claim re-reads its secret so a rotated or revoked link fails closed."
        }
      },
      "description": "Approved WhatsApp template content frozen at handoff, including the rendered invite variables; sender credentials never appear here."
    }
  },
  "title": "AutomationDeliveryMessageIntent"
} as const;
