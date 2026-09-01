/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Complete supported Host Today attention items plus explicit coverage for client-merged, shortcut-only, and blocked-missing-truth kinds.
 */
export interface ListOrganizerAttentionItemsCallableResponse {
  organizerId: string;
  policyVersion: number;
  generatedAtMillis: number;
  horizonEndsAtMillis: number;
  /**
   * @maxItems 400
   */
  items: {
    attentionId: string;
    kind:
      | "eventLiveOperations"
      | "eventWaitlistReview"
      | "applicationReview"
      | "providerSyncFailure"
      | "formAutomationFailure"
      | "payoutSetup"
      | "attendanceSync"
      | "dressRehearsal"
      | "eventSuccessPreparation"
      | "roomLayoutSetup"
      | "eventStaffing"
      | "formResponseReview"
      | "inboxReply"
      | "postEventReconciliation";
    scope:
      | "organizer"
      | "event"
      | "application"
      | "form"
      | "thread"
      | "account";
    sourceOwner:
      | "events"
      | "organizerApplications"
      | "providerSyncRuns"
      | "organizerFormAutomationRuns"
      | "hostPaymentAccounts"
      | "hostAttendanceOutbox"
      | "eventSuccessPlans"
      | "eventRehearsals"
      | "eventStaffGrants"
      | "organizerFormResponses"
      | "organizerWhatsappThreads"
      | "eventAttendees";
    sourceId: string;
    sourceRevision: string;
    eventId: string | null;
    status: "open";
    consequence:
      | "blocksLiveOperation"
      | "risksGuestExperience"
      | "risksRevenue"
      | "delaysResponse"
      | "degradesAutomation"
      | "requiresReconciliation"
      | "preparationIncomplete"
      | "informational";
    blocking: boolean;
    urgency: "immediate" | "soon" | "upcoming";
    destination: {
      route:
        | "hostEventManage"
        | "hostApplications"
        | "hostOrganizerPayments"
        | "hostAudienceForms"
        | "hostInbox"
        | "hostDressRehearsal"
        | "hostEvents";
      section: string | null;
      eventId: string | null;
      applicationId: string | null;
      formId: string | null;
      threadId: string | null;
    };
    context: {
      eventName: string | null;
      subjectLabel: string | null;
      count: number | null;
      provider: string | null;
      errorCode: string | null;
    };
    dedupeKey: string;
    policyVersion: number;
    resolutionVersion: number;
    assignedHostUid: string | null;
    openedAtMillis: number;
    dueAtMillis: number;
    expiresAtMillis: number | null;
  }[];
  /**
   * @minItems 14
   * @maxItems 14
   */
  coverage: {
    kind:
      | "eventLiveOperations"
      | "eventWaitlistReview"
      | "applicationReview"
      | "providerSyncFailure"
      | "formAutomationFailure"
      | "payoutSetup"
      | "attendanceSync"
      | "dressRehearsal"
      | "eventSuccessPreparation"
      | "roomLayoutSetup"
      | "eventStaffing"
      | "formResponseReview"
      | "inboxReply"
      | "postEventReconciliation";
    state:
      | "complete"
      | "clientMergeRequired"
      | "shortcutOnly"
      | "blockedMissingTruth";
    reason: string;
  }[];
}
