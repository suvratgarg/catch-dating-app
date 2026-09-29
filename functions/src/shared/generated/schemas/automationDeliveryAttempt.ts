/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const automationDeliveryAttemptSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "attemptId",
    "intentId",
    "intentRevision",
    "ordinal",
    "createdAt",
    "state",
    "mode",
    "context",
    "binding",
    "authorization"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1,
      "type": "integer"
    },
    "attemptId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
    },
    "intentId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
    },
    "intentRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000000
    },
    "ordinal": {
      "type": "integer",
      "minimum": 1,
      "maximum": 6
    },
    "createdAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "state": {
      "oneOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "at",
            "reconcileAfter"
          ],
          "properties": {
            "kind": {
              "const": "reserved",
              "type": "string"
            },
            "at": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "reconcileAfter": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "at",
            "providerMessageId",
            "reason",
            "reconcileAfter"
          ],
          "properties": {
            "kind": {
              "const": "unknown",
              "type": "string"
            },
            "at": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "providerMessageId": {
              "anyOf": [
                {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 512
                },
                {
                  "type": "null"
                }
              ]
            },
            "reason": {
              "type": "string",
              "enum": [
                "timeout",
                "connectionLost",
                "workerInterrupted"
              ]
            },
            "reconcileAfter": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "at",
            "providerMessageId"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "enum": [
                "accepted",
                "delivered",
                "read"
              ]
            },
            "at": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "providerMessageId": {
              "anyOf": [
                {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 512
                },
                {
                  "type": "null"
                }
              ]
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "at",
            "providerMessageId",
            "classification",
            "evidenceId"
          ],
          "properties": {
            "kind": {
              "const": "failed",
              "type": "string"
            },
            "at": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "providerMessageId": {
              "anyOf": [
                {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 512
                },
                {
                  "type": "null"
                }
              ]
            },
            "classification": {
              "type": "string",
              "enum": [
                "technical",
                "policy",
                "suppressed",
                "invalidRecipient"
              ]
            },
            "evidenceId": {
              "anyOf": [
                {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                {
                  "type": "null"
                }
              ]
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "at",
            "providerMessageId",
            "evidenceId"
          ],
          "properties": {
            "kind": {
              "const": "revoked",
              "type": "string"
            },
            "at": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "providerMessageId": {
              "anyOf": [
                {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 512
                },
                {
                  "type": "null"
                }
              ]
            },
            "evidenceId": {
              "anyOf": [
                {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                {
                  "type": "null"
                }
              ]
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "at",
            "reason"
          ],
          "properties": {
            "kind": {
              "const": "notDispatched",
              "type": "string"
            },
            "at": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "reason": {
              "type": "string",
              "enum": [
                "superseded",
                "expired",
                "permissionRevoked",
                "reservationExpired",
                "permitExpired",
                "campaignEnded",
                "recipientWithdrawn"
              ]
            }
          }
        }
      ]
    },
    "mode": {
      "const": "live",
      "type": "string"
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
    "binding": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "routeId",
        "transport",
        "senderIdentity",
        "provider",
        "senderId",
        "bindingRevision",
        "recipientEndpointId",
        "fallbackOwner"
      ],
      "properties": {
        "routeId": {
          "const": "organizerWhatsappAutomation",
          "type": "string"
        },
        "transport": {
          "const": "whatsapp",
          "type": "string"
        },
        "senderIdentity": {
          "const": "organizerManaged",
          "type": "string"
        },
        "provider": {
          "type": "string",
          "enum": [
            "meta"
          ]
        },
        "senderId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$",
          "description": "organizerSenderConnections document id that owns the send."
        },
        "bindingRevision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        },
        "recipientEndpointId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
        },
        "fallbackOwner": {
          "type": "string",
          "enum": [
            "catch"
          ]
        }
      }
    },
    "authorization": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "permissionRevision",
        "checkedAt",
        "validUntil",
        "instructionRevision"
      ],
      "properties": {
        "permissionRevision": {
          "type": "string",
          "minLength": 1,
          "maxLength": 512
        },
        "checkedAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "validUntil": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "instructionRevision": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        }
      }
    }
  },
  "title": "AutomationDeliveryAttempt"
} as const;
