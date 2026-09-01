/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned evaluated Host Today attention projection. Executable trigger, resolution, permission, deadline, and dedupe policy remains versioned in the Host attention catalog rather than embedded as prose in each document.
 */
export interface OrganizerAttentionItemDocument {
  schemaVersion: 1;
  attentionId: string;
  organizerId: string;
  kind:
    | "eventLiveOperations"
    | "eventWaitlistReview"
    | "eventJoinRequestReview"
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
  scope: "organizer" | "event" | "application" | "form" | "thread" | "account";
  sourceOwner:
    | "events"
    | "eventParticipations"
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
  status: "open" | "resolved" | "expired" | "superseded";
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
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  openedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  dueAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  actionExpiresAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  sourceUpdatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  resolvedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  purgeAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
}
