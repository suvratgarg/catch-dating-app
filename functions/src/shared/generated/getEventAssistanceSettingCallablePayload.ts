/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface GetEventAssistanceSettingCallablePayload {
  context: {
    mode: "live";
    eventId: string;
    organizerId: string;
  };
  groupId: string;
  workflowKind:
    | "venueReadiness"
    | "routeReadiness"
    | "formatReadiness"
    | "rosterReadiness"
    | "requiredGuestData"
    | "resourceReadiness"
    | "staffingReadiness"
    | "messagingReadiness"
    | "admissionReview"
    | "financialReadiness"
    | "joiningInstructions"
    | "identityResolution"
    | "guestAdmission"
    | "guestCheckIn"
    | "lateJoin"
    | "participationChange"
    | "guestPrerequisite"
    | "allocationRepair"
    | "placementConfirmation"
    | "resourceRecovery"
    | "fairParticipation"
    | "roundPublication"
    | "unitProgress"
    | "outcomeRecording"
    | "programmeRecovery"
    | "departure"
    | "checkpoint"
    | "groupTransfer"
    | "routeRecovery"
    | "locationFreshness"
    | "accountability"
    | "planChangeCommunication"
    | "deliveryRecovery"
    | "replyOwnership"
    | "guestAssistance"
    | "comfortSafety"
    | "attendanceSync"
    | "concurrencyRecovery"
    | "operationRecovery"
    | "contextBoundary"
    | "overrideReview"
    | "eventClosure"
    | "attendanceReconciliation"
    | "financialReconciliation"
    | "postEventFollowUp"
    | "eventLearning";
}
