/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Idempotent, observable execution of one rule revision for one response event.
 */
export interface OrganizerFormAutomationRunDocument {
  organizerId: string;
  formId: string | null;
  ruleId: string;
  ruleRevision: number;
  responseId: string | null;
  eventKind:
    | "submitted"
    | "withdrawn"
    | "applicationAccepted"
    | "eventAttended";
  status:
    | "pending"
    | "running"
    | "succeeded"
    | "partiallyFailed"
    | "failed"
    | "skipped";
  attemptCount: number;
  /**
   * @maxItems 10
   */
  actionResults: {
    actionId: string;
    kind:
      | "notifyTeam"
      | "addOrganizerTag"
      | "createCrmContact"
      | "addApplicationQueue"
      | "proposeEventAttendee"
      | "signedWebhook"
      | "campaignHandoff";
    status: "succeeded" | "failed" | "skipped";
    resultId: string | null;
    errorCode: string | null;
  }[];
  errorCode: string | null;
  errorMessage: string | null;
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
  completedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  sourceId?: string;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  sourceOccurredAt?: {
    _seconds: number;
    _nanoseconds: number;
  };
  dueAt?: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  leaseOwner?: string | null;
  leaseExpiresAt?: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
}
