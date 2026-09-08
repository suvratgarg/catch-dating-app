/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventRcsDispatchDocumentSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "attemptId",
    "messageId",
    "context",
    "senderId",
    "agentId",
    "region",
    "bindingRevision",
    "configHash",
    "permissionId",
    "permissionRevision",
    "permissionHash",
    "recipientEndpointId",
    "endpointHash",
    "capability",
    "grantId",
    "guestGrantHash",
    "payloadHash",
    "authorityHash",
    "providerMessageId",
    "expiresAt",
    "createdAt",
    "quoteRevision",
    "currency",
    "maxCostMicros",
    "budgetDebits",
    "attendeeId",
    "intentHash",
    "attemptScopeHash",
    "replyBinding"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "attemptId": {
      "type": "string",
      "pattern": "^attempt:[a-f0-9]{64}$"
    },
    "messageId": {
      "type": "string",
      "pattern": "^outbox:[a-f0-9]{64}$"
    },
    "context": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "mode",
        "organizerId",
        "eventId"
      ],
      "properties": {
        "mode": {
          "type": "string",
          "const": "live"
        },
        "organizerId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "eventId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        }
      }
    },
    "senderId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
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
    "permissionHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "recipientEndpointId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "endpointHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "capability": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "requestId",
        "senderId",
        "agentId",
        "recipientEndpointId",
        "configHash",
        "permissionHash",
        "checkedAt",
        "validUntil",
        "supportsOpenUrl"
      ],
      "properties": {
        "requestId": {
          "type": "string",
          "pattern": "^[a-f0-9]{8}-[a-f0-9]{4}-[1-5][a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}$"
        },
        "senderId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "agentId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 512,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._@-]*$"
        },
        "recipientEndpointId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "configHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "permissionHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
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
        "supportsOpenUrl": {
          "type": "boolean"
        }
      }
    },
    "grantId": {
      "type": "string",
      "pattern": "^[a-f0-9]{32}$"
    },
    "guestGrantHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "payloadHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "authorityHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "providerMessageId": {
      "type": "string",
      "pattern": "^[a-f0-9]{8}-[a-f0-9]{4}-[1-5][a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}$"
    },
    "expiresAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "createdAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "quoteRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "currency": {
      "type": "string",
      "pattern": "^[A-Z]{3}$"
    },
    "maxCostMicros": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000000000
    },
    "budgetDebits": {
      "type": "array",
      "minItems": 2,
      "maxItems": 2,
      "uniqueItems": true,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "budgetId",
          "approvalId",
          "revisionBefore",
          "revisionAfter",
          "chargedBeforeMicros",
          "chargedAfterMicros"
        ],
        "properties": {
          "budgetId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          },
          "approvalId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          },
          "revisionBefore": {
            "type": "integer",
            "minimum": 1,
            "maximum": 9007199254740991
          },
          "revisionAfter": {
            "type": "integer",
            "minimum": 1,
            "maximum": 9007199254740991
          },
          "chargedBeforeMicros": {
            "type": "integer",
            "minimum": 0,
            "maximum": 9007199254740991
          },
          "chargedAfterMicros": {
            "type": "integer",
            "minimum": 0,
            "maximum": 9007199254740991
          }
        }
      }
    },
    "attendeeId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "intentHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "attemptScopeHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "replyBinding": {
      "anyOf": [
        {
          "type": "null"
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "guestId",
            "episodeId",
            "guestRevision",
            "attendeeGeneration",
            "sourceGeneration",
            "subjectUid",
            "expiresAt",
            "choices"
          ],
          "properties": {
            "guestId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "episodeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "guestRevision": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "attendeeGeneration": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "sourceGeneration": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "subjectUid": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "expiresAt": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "choices": {
              "type": "array",
              "minItems": 1,
              "maxItems": 10,
              "uniqueItems": true,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "index",
                  "choiceId"
                ],
                "properties": {
                  "index": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 9
                  },
                  "choiceId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 160,
                    "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                  }
                }
              }
            }
          }
        }
      ]
    }
  },
  "title": "EventRcsDispatchDocument",
  "x-firestore-collection": "eventAssistanceRcsDispatches",
  "x-firestore-path": "eventAssistanceRcsDispatches/{attemptId}",
  "x-document-id-field": "attemptId",
  "x-owner": "event-service RCS dispatch"
} as const;
