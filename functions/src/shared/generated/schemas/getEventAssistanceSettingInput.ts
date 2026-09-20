/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getEventAssistanceSettingCallablePayloadSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "context",
    "groupId",
    "workflowKind"
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
    "groupId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "workflowKind": {
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
    }
  },
  "title": "GetEventAssistanceSettingCallablePayload"
} as const;
