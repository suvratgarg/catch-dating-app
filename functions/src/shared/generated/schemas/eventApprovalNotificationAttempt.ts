/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventApprovalNotificationAttemptSchema: Record<string, unknown> = {
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
    "authorization",
    "mode",
    "context",
    "binding"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "attemptId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "intentId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "intentRevision": {
      "type": "integer",
      "const": 1
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
    },
    "mode": {
      "type": "string",
      "const": "live"
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
    "binding": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "routeId",
        "senderId",
        "bindingRevision",
        "recipientEndpointId",
        "fallbackOwner"
      ],
      "properties": {
        "routeId": {
          "type": "string",
          "enum": [
            "approvalWhatsapp",
            "approvalSms",
            "approvalEmail"
          ]
        },
        "senderId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "bindingRevision": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "recipientEndpointId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "fallbackOwner": {
          "type": "string",
          "const": "catch"
        }
      }
    }
  },
  "title": "EventApprovalNotificationAttempt"
} as const;
