/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listOrganizerAttentionItemsCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/list_organizer_attention_items_response.schema.json",
  "title": "ListOrganizerAttentionItemsCallableResponse",
  "description": "Complete supported Host Today attention items plus explicit coverage for client-merged, shortcut-only, and blocked-missing-truth kinds.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "policyVersion",
    "generatedAtMillis",
    "horizonEndsAtMillis",
    "items",
    "coverage"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "policyVersion": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000000
    },
    "generatedAtMillis": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "horizonEndsAtMillis": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "items": {
      "type": "array",
      "maxItems": 400,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "attentionId",
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
          "openedAtMillis",
          "dueAtMillis",
          "expiresAtMillis"
        ],
        "properties": {
          "attentionId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
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
            "x-catch-catalog": "../catalogs/host_attention_policies.json"
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
            ]
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
            ]
          },
          "sourceId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "sourceRevision": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "eventId": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 180
          },
          "status": {
            "const": "open"
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
            ]
          },
          "blocking": {
            "type": "boolean"
          },
          "urgency": {
            "type": "string",
            "enum": [
              "immediate",
              "soon",
              "upcoming"
            ]
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
            }
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
            }
          },
          "dedupeKey": {
            "type": "string",
            "minLength": 1,
            "maxLength": 240
          },
          "policyVersion": {
            "type": "integer",
            "minimum": 1,
            "maximum": 1000000
          },
          "resolutionVersion": {
            "type": "integer",
            "minimum": 1,
            "maximum": 1000000
          },
          "assignedHostUid": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 180
          },
          "openedAtMillis": {
            "type": "integer",
            "minimum": 0,
            "maximum": 9007199254740991
          },
          "dueAtMillis": {
            "type": "integer",
            "minimum": 0,
            "maximum": 9007199254740991
          },
          "expiresAtMillis": {
            "type": [
              "integer",
              "null"
            ],
            "minimum": 0,
            "maximum": 9007199254740991
          }
        }
      }
    },
    "coverage": {
      "type": "array",
      "minItems": 15,
      "maxItems": 15,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "kind",
          "state",
          "reason"
        ],
        "properties": {
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
            "x-catch-catalog": "../catalogs/host_attention_policies.json"
          },
          "state": {
            "type": "string",
            "enum": [
              "complete",
              "clientMergeRequired",
              "shortcutOnly",
              "blockedMissingTruth"
            ]
          },
          "reason": {
            "type": "string",
            "minLength": 1,
            "maxLength": 500
          }
        }
      }
    }
  }
} as const;
