/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Latest finance review decision for one event, route, sender, and purpose. This record grants no spending authority and is not a dispatch budget.
 */
export interface EventMessagingBudgetDecisionDocument {
  schemaVersion: 1;
  decisionId: string;
  revision: number;
  requestId: string;
  requestHash: string;
  context: {
    mode: "live";
    eventId: string;
    organizerId: string;
  };
  routeId: "catchEventSms" | "catchEventRcs" | "organizerEventWhatsapp";
  senderId: string;
  purpose:
    | "joiningUpdate"
    | "joiningInstructions"
    | "planChanged"
    | "eventCancelled"
    | "eventFinished"
    | "guestRequirement"
    | "assignmentChanged"
    | "participationCheck"
    | "followUp";
  decision:
    | {
        kind: "approve";
        currency: string;
        eventLimitMicros: number;
        senderDayLimitMicros: number;
        validUntil: number;
      }
    | {
        kind: "hold";
      }
    | {
        kind: "reject";
      };
  decisionStatus: "approved" | "held" | "rejected";
  reviewEvidence: {
    observedAt: number;
    completedAt: number;
    eventEnd: number;
    runtimeSourceHash: string;
    senderReviewHash: string;
    budgetSourceHash: string;
    setupReviewHash: string;
    eventBudget: {
      budgetId: string;
      revision: number | null;
      reviewHash: string | null;
      chargedMicros: number;
    };
    senderDayBudget: {
      budgetId: string;
      revision: number | null;
      reviewHash: string | null;
      chargedMicros: number;
    };
  };
  reviewedByUid: string;
  note: string;
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
  effect: "decision_only_no_spending_authority";
  grantsSpendingAuthority: false;
}
