/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceThreadDocumentSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "threadId",
    "guestId",
    "context",
    "attendeeId",
    "episodeId",
    "workflow",
    "messageId",
    "revision",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "threadId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "guestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
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
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "episodeId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "workflow": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "kind",
        "occurrenceId"
      ],
      "properties": {
        "kind": {
          "type": "string",
          "enum": [
            "venueReadiness",
            "routeReadiness",
            "formatReadiness",
            "rosterReadiness",
            "requiredGuestData",
            "resourceReadiness",
            "staffingReadiness",
            "messagingReadiness",
            "admissionReview",
            "financialReadiness",
            "joiningInstructions",
            "identityResolution",
            "guestAdmission",
            "guestCheckIn",
            "lateJoin",
            "participationChange",
            "guestPrerequisite",
            "allocationRepair",
            "placementConfirmation",
            "resourceRecovery",
            "fairParticipation",
            "roundPublication",
            "unitProgress",
            "outcomeRecording",
            "programmeRecovery",
            "departure",
            "checkpoint",
            "groupTransfer",
            "routeRecovery",
            "locationFreshness",
            "accountability",
            "planChangeCommunication",
            "deliveryRecovery",
            "replyOwnership",
            "guestAssistance",
            "comfortSafety",
            "attendanceSync",
            "concurrencyRecovery",
            "operationRecovery",
            "contextBoundary",
            "overrideReview",
            "eventClosure",
            "attendanceReconciliation",
            "financialReconciliation",
            "postEventFollowUp",
            "eventLearning"
          ],
          "x-catch-catalog": "../catalogs/event_assistance_workflows.json"
        },
        "occurrenceId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
        }
      }
    },
    "messageId": {
      "type": "string",
      "pattern": "^outbox:[a-f0-9]{64}$"
    },
    "revision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "createdAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "updatedAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    }
  },
  "title": "EventAssistanceThreadDocument",
  "x-firestore-collection": "eventAssistanceThreads",
  "x-firestore-path": "eventAssistanceThreads/{threadId}",
  "x-document-id-field": "threadId",
  "x-owner": "trusted event-assistance guest boundary"
} as const;
