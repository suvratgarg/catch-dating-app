/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerFormAutomationRunDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_form_automation_runs.schema.json",
  "title": "OrganizerFormAutomationRunDocument",
  "description": "Idempotent, observable execution of one rule revision for one response event.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "formId",
    "ruleId",
    "ruleRevision",
    "responseId",
    "eventKind",
    "status",
    "attemptCount",
    "actionResults",
    "errorCode",
    "errorMessage",
    "createdAt",
    "updatedAt",
    "completedAt"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "formId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    },
    "ruleId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "ruleRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "responseId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
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
    "status": {
      "type": "string",
      "enum": [
        "pending",
        "running",
        "succeeded",
        "partiallyFailed",
        "failed",
        "skipped"
      ]
    },
    "attemptCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100
    },
    "actionResults": {
      "type": "array",
      "maxItems": 10,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "actionId",
          "kind",
          "status",
          "resultId",
          "errorCode"
        ],
        "properties": {
          "actionId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "kind": {
            "type": "string",
            "enum": [
              "notifyTeam",
              "addOrganizerTag",
              "createCrmContact",
              "addApplicationQueue",
              "proposeEventAttendee",
              "signedWebhook",
              "campaignHandoff"
            ]
          },
          "status": {
            "type": "string",
            "enum": [
              "succeeded",
              "failed",
              "skipped"
            ]
          },
          "resultId": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 200
          },
          "errorCode": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 80
          }
        }
      }
    },
    "errorCode": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 80
    },
    "errorMessage": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 500
    },
    "createdAt": {
      "type": "object",
      "description": "Serialized Firestore Timestamp fixture shape.",
      "x-firestore-type": "timestamp",
      "additionalProperties": false,
      "required": [
        "_seconds",
        "_nanoseconds"
      ],
      "properties": {
        "_seconds": {
          "type": "integer"
        },
        "_nanoseconds": {
          "type": "integer",
          "minimum": 0,
          "maximum": 999999999
        }
      }
    },
    "updatedAt": {
      "type": "object",
      "description": "Serialized Firestore Timestamp fixture shape.",
      "x-firestore-type": "timestamp",
      "additionalProperties": false,
      "required": [
        "_seconds",
        "_nanoseconds"
      ],
      "properties": {
        "_seconds": {
          "type": "integer"
        },
        "_nanoseconds": {
          "type": "integer",
          "minimum": 0,
          "maximum": 999999999
        }
      }
    },
    "completedAt": {
      "anyOf": [
        {
          "type": "object",
          "description": "Serialized Firestore Timestamp fixture shape.",
          "x-firestore-type": "timestamp",
          "additionalProperties": false,
          "required": [
            "_seconds",
            "_nanoseconds"
          ],
          "properties": {
            "_seconds": {
              "type": "integer"
            },
            "_nanoseconds": {
              "type": "integer",
              "minimum": 0,
              "maximum": 999999999
            }
          }
        },
        {
          "type": "null"
        }
      ]
    },
    "sourceId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "sourceOccurredAt": {
      "type": "object",
      "description": "Serialized Firestore Timestamp fixture shape.",
      "x-firestore-type": "timestamp",
      "additionalProperties": false,
      "required": [
        "_seconds",
        "_nanoseconds"
      ],
      "properties": {
        "_seconds": {
          "type": "integer"
        },
        "_nanoseconds": {
          "type": "integer",
          "minimum": 0,
          "maximum": 999999999
        }
      }
    },
    "dueAt": {
      "anyOf": [
        {
          "type": "object",
          "description": "Serialized Firestore Timestamp fixture shape.",
          "x-firestore-type": "timestamp",
          "additionalProperties": false,
          "required": [
            "_seconds",
            "_nanoseconds"
          ],
          "properties": {
            "_seconds": {
              "type": "integer"
            },
            "_nanoseconds": {
              "type": "integer",
              "minimum": 0,
              "maximum": 999999999
            }
          }
        },
        {
          "type": "null"
        }
      ]
    },
    "leaseOwner": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 180
    },
    "leaseExpiresAt": {
      "anyOf": [
        {
          "type": "object",
          "description": "Serialized Firestore Timestamp fixture shape.",
          "x-firestore-type": "timestamp",
          "additionalProperties": false,
          "required": [
            "_seconds",
            "_nanoseconds"
          ],
          "properties": {
            "_seconds": {
              "type": "integer"
            },
            "_nanoseconds": {
              "type": "integer",
              "minimum": 0,
              "maximum": 999999999
            }
          }
        },
        {
          "type": "null"
        }
      ]
    }
  },
  "x-firestore-collection": "organizerFormAutomationRuns",
  "x-firestore-path": "organizerFormAutomationRuns/{runId}",
  "x-document-id-field": "runId",
  "x-owner": "organizer form automation executor"
} as const;
