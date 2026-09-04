/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerManualSendTaskDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_manual_send_tasks.schema.json",
  "title": "OrganizerManualSendTaskDocument",
  "description": "One durable host-performed external handoff. Catch may record preparation, external-app acceptance, and explicit host assertions, but never delivery or read state.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerManualSendTasks",
  "x-firestore-path": "organizerManualSendTasks/{taskId}",
  "x-document-id-field": "taskId",
  "x-owner": "manager-only organizer manual-send callables",
  "required": [
    "organizerId",
    "taskId",
    "contactId",
    "sourceKind",
    "sourceId",
    "intent",
    "routeId",
    "deliveryMode",
    "status",
    "active",
    "revision",
    "idempotencyKey",
    "requestHash",
    "displayNameSnapshot",
    "endpointE164Snapshot",
    "endpointHash",
    "permissionSnapshot",
    "capabilitySnapshot",
    "prefillText",
    "prefillHash",
    "openCount",
    "createdByUid",
    "updatedByUid",
    "createdAt",
    "updatedAt",
    "openedAt",
    "hostMarkedSentAt",
    "skippedAt",
    "cancelledAt",
    "supersededAt",
    "expiresAt"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "taskId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "contactId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "sourceKind": {
      "type": "string",
      "enum": [
        "individualConversation",
        "campaignRecipient"
      ]
    },
    "sourceId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "intent": {
      "type": "string",
      "enum": [
        "individualConversation",
        "savedAudienceCampaign"
      ]
    },
    "routeId": {
      "const": "personalWhatsappHandoff"
    },
    "deliveryMode": {
      "const": "byHand"
    },
    "status": {
      "type": "string",
      "enum": [
        "queued",
        "handoffOpened",
        "hostMarkedSent",
        "skipped",
        "cancelled",
        "superseded",
        "expired"
      ]
    },
    "active": {
      "type": "boolean"
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "idempotencyKey": {
      "type": "string",
      "minLength": 8,
      "maxLength": 120
    },
    "requestHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "displayNameSnapshot": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "endpointE164Snapshot": {
      "type": "string",
      "pattern": "^\\+[1-9][0-9]{7,14}$"
    },
    "endpointHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "permissionSnapshot": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "whatsappStatus",
        "adminSuppressed",
        "recordedAt"
      ],
      "properties": {
        "whatsappStatus": {
          "type": "string",
          "enum": [
            "unknown",
            "optedIn"
          ]
        },
        "adminSuppressed": {
          "const": false
        },
        "recordedAt": {
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
        }
      }
    },
    "capabilitySnapshot": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "version",
        "managedRouteAvailable"
      ],
      "properties": {
        "version": {
          "type": "integer",
          "minimum": 1,
          "maximum": 1000
        },
        "managedRouteAvailable": {
          "type": "boolean"
        }
      }
    },
    "prefillText": {
      "type": "string",
      "minLength": 1,
      "maxLength": 1000
    },
    "prefillHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "openCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 1000
    },
    "createdByUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "updatedByUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
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
    "openedAt": {
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
    "hostMarkedSentAt": {
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
    "skippedAt": {
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
    "cancelledAt": {
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
    "supersededAt": {
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
    "expiresAt": {
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
    }
  },
  "definitions": {
    "status": {
      "type": "string",
      "enum": [
        "queued",
        "handoffOpened",
        "hostMarkedSent",
        "skipped",
        "cancelled",
        "superseded",
        "expired"
      ]
    }
  }
} as const;
