/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceDeliveryWorkSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/operations/event_assistance_delivery_work.schema.json",
  "title": "EventAssistanceDeliveryWork",
  "description": "Private resumable delivery coordination for one published automatic message. The outbox owns provider attempts; a checkpoint never grants dispatch authority.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "kind",
    "messageId",
    "intentHash",
    "threadId",
    "scope",
    "createdAt",
    "expiresAt",
    "checkpoint"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "kind": {
      "type": "string",
      "const": "liveMessageDelivery"
    },
    "messageId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "intentHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "threadId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "scope": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "context",
        "attendeeId",
        "episodeId"
      ],
      "properties": {
        "context": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "mode",
            "eventId",
            "organizerId"
          ],
          "properties": {
            "mode": {
              "type": "string",
              "const": "live"
            },
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "organizerId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 2000
            }
          }
        },
        "attendeeId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "episodeId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
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
    "checkpoint": {
      "oneOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "phase",
            "reason",
            "dueAt",
            "messageRevision",
            "messageHash",
            "failures",
            "evaluations"
          ],
          "properties": {
            "phase": {
              "type": "string",
              "const": "queued"
            },
            "reason": {
              "type": "null"
            },
            "dueAt": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "messageRevision": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "messageHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "failures": {
              "type": "integer",
              "minimum": 0,
              "maximum": 5,
              "const": 0
            },
            "evaluations": {
              "type": "integer",
              "minimum": 0,
              "maximum": 100,
              "const": 0
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "phase",
            "reason",
            "dueAt",
            "messageRevision",
            "messageHash",
            "failures",
            "evaluations"
          ],
          "properties": {
            "phase": {
              "type": "string",
              "const": "complete"
            },
            "reason": {
              "enum": [
                "delivered",
                "responded",
                "cancelled",
                "superseded",
                "expired",
                "eventClosed",
                "permissionRevoked",
                "guestPresent",
                "guestDeclined",
                "notAdmitted",
                "hostStopped",
                "participationInactive"
              ]
            },
            "dueAt": {
              "type": "null"
            },
            "messageRevision": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "messageHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "failures": {
              "type": "integer",
              "minimum": 0,
              "maximum": 5
            },
            "evaluations": {
              "type": "integer",
              "minimum": 0,
              "maximum": 100
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "phase",
            "reason",
            "dueAt",
            "messageRevision",
            "messageHash",
            "failures",
            "evaluations"
          ],
          "properties": {
            "phase": {
              "type": "string",
              "const": "receipt"
            },
            "reason": {
              "const": "providerPending"
            },
            "dueAt": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "messageRevision": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "messageHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "failures": {
              "type": "integer",
              "minimum": 0,
              "maximum": 5
            },
            "evaluations": {
              "type": "integer",
              "minimum": 0,
              "maximum": 100
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "phase",
            "reason",
            "dueAt",
            "messageRevision",
            "messageHash",
            "failures",
            "evaluations"
          ],
          "properties": {
            "phase": {
              "type": "string",
              "const": "retry"
            },
            "reason": {
              "enum": [
                "retryBackoff",
                "eventFactsStale",
                "routeFactsStale",
                "workerUnavailable"
              ]
            },
            "dueAt": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "messageRevision": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "messageHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "failures": {
              "type": "integer",
              "minimum": 0,
              "maximum": 5
            },
            "evaluations": {
              "type": "integer",
              "minimum": 0,
              "maximum": 100
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "phase",
            "reason",
            "dueAt",
            "messageRevision",
            "messageHash",
            "failures",
            "evaluations"
          ],
          "properties": {
            "phase": {
              "type": "string",
              "const": "review"
            },
            "reason": {
              "enum": [
                "noEligibleRoute",
                "attemptLimit",
                "policyRejected",
                "recipientNeedsReview",
                "providerOwnsFallback",
                "conflictingDeliveryEvidence",
                "providerPending",
                "workerUnavailable",
                "recoveryLimit",
                "eventFactsStale",
                "routeFactsStale"
              ]
            },
            "dueAt": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "messageRevision": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "messageHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "failures": {
              "type": "integer",
              "minimum": 0,
              "maximum": 5
            },
            "evaluations": {
              "type": "integer",
              "minimum": 0,
              "maximum": 100
            }
          }
        }
      ]
    }
  }
} as const;
