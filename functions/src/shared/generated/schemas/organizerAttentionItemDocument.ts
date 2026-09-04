/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerAttentionItemDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_attention_items.schema.json",
  "title": "OrganizerAttentionItemDocument",
  "description": "Server-owned evaluated Host Today attention projection. Executable trigger, resolution, permission, deadline, and dedupe policy remains versioned in the Host attention catalog rather than embedded as prose in each document.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerAttentionItems",
  "x-firestore-path": "organizerAttentionItems/{attentionId}",
  "x-document-id-field": "attentionId",
  "x-owner": "listOrganizerAttentionItems read-through reconciliation",
  "required": [
    "schemaVersion",
    "attentionId",
    "organizerId",
    "kind",
    "scope",
    "sourceOwner",
    "sourceId",
    "sourceRevision",
    "eventId",
    "status",
    "consequence",
    "blocking",
    "urgency",
    "destination",
    "context",
    "dedupeKey",
    "policyVersion",
    "resolutionVersion",
    "assignedHostUid",
    "openedAt",
    "dueAt",
    "actionExpiresAt",
    "sourceUpdatedAt",
    "createdAt",
    "updatedAt",
    "resolvedAt",
    "purgeAt"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1,
      "x-catch-ownership": "server-only"
    },
    "attentionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "kind": {
      "type": "string",
      "enum": [
        "eventLiveOperations",
        "eventWaitlistReview",
        "eventJoinRequestReview",
        "applicationReview",
        "providerSyncFailure",
        "formAutomationFailure",
        "payoutSetup",
        "attendanceSync",
        "dressRehearsal",
        "eventSuccessPreparation",
        "roomLayoutSetup",
        "eventStaffing",
        "formResponseReview",
        "inboxReply",
        "postEventReconciliation"
      ],
      "x-catch-catalog": "../catalogs/host_attention_policies.json",
      "x-catch-ownership": "server-only"
    },
    "scope": {
      "type": "string",
      "enum": [
        "organizer",
        "event",
        "application",
        "form",
        "thread",
        "account"
      ],
      "x-catch-ownership": "server-only"
    },
    "sourceOwner": {
      "type": "string",
      "enum": [
        "events",
        "eventParticipations",
        "organizerApplications",
        "providerSyncRuns",
        "organizerFormAutomationRuns",
        "hostPaymentAccounts",
        "hostAttendanceOutbox",
        "eventSuccessPlans",
        "eventRehearsals",
        "eventStaffGrants",
        "organizerFormResponses",
        "organizerWhatsappThreads",
        "eventAttendees"
      ],
      "x-catch-ownership": "server-only"
    },
    "sourceId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "sourceRevision": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "eventId": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "status": {
      "type": "string",
      "enum": [
        "open",
        "resolved",
        "expired",
        "superseded"
      ],
      "x-catch-ownership": "server-only"
    },
    "consequence": {
      "type": "string",
      "enum": [
        "blocksLiveOperation",
        "risksGuestExperience",
        "risksRevenue",
        "delaysResponse",
        "degradesAutomation",
        "requiresReconciliation",
        "preparationIncomplete",
        "informational"
      ],
      "x-catch-ownership": "server-only"
    },
    "blocking": {
      "type": "boolean",
      "x-catch-ownership": "server-only"
    },
    "urgency": {
      "type": "string",
      "enum": [
        "immediate",
        "soon",
        "upcoming"
      ],
      "x-catch-ownership": "server-only"
    },
    "destination": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "route",
        "section",
        "eventId",
        "applicationId",
        "formId",
        "threadId"
      ],
      "properties": {
        "route": {
          "type": "string",
          "enum": [
            "hostEventManage",
            "hostApplications",
            "hostOrganizerPayments",
            "hostAudienceForms",
            "hostInbox",
            "hostDressRehearsal",
            "hostEvents"
          ]
        },
        "section": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 80
        },
        "eventId": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 180
        },
        "applicationId": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 180
        },
        "formId": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 180
        },
        "threadId": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 180
        }
      },
      "x-catch-ownership": "server-only"
    },
    "context": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "eventName",
        "subjectLabel",
        "count",
        "provider",
        "errorCode"
      ],
      "properties": {
        "eventName": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 160
        },
        "subjectLabel": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 160
        },
        "count": {
          "type": [
            "integer",
            "null"
          ],
          "minimum": 0,
          "maximum": 1000000000
        },
        "provider": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 80
        },
        "errorCode": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 120
        }
      },
      "x-catch-ownership": "server-only"
    },
    "dedupeKey": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240,
      "x-catch-ownership": "server-only"
    },
    "policyVersion": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000000,
      "x-catch-ownership": "server-only"
    },
    "resolutionVersion": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000000,
      "x-catch-ownership": "server-only"
    },
    "assignedHostUid": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "openedAt": {
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
      },
      "x-catch-ownership": "server-only"
    },
    "dueAt": {
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
      },
      "x-catch-ownership": "server-only"
    },
    "actionExpiresAt": {
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
      ],
      "x-catch-ownership": "server-only"
    },
    "sourceUpdatedAt": {
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
      },
      "x-catch-ownership": "server-only"
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
      },
      "x-catch-ownership": "server-only"
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
      },
      "x-catch-ownership": "server-only"
    },
    "resolvedAt": {
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
      ],
      "x-catch-ownership": "server-only"
    },
    "purgeAt": {
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
      ],
      "x-firestore-ttl": true,
      "x-catch-ownership": "server-only"
    }
  }
} as const;
