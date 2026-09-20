/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Immutable evidence that one still-current approved decision staged both channel spending ceilings in paused state. The receipt and budgets grant no spending or dispatch authority until a separate live activation boundary succeeds.
 */
export interface EventMessagingBudgetApplicationReceiptDocument {
  schemaVersion: 1;
  receiptId: string;
  requestId: string;
  requestHash: string;
  decisionId: string;
  decisionRevision: number;
  decisionReviewHash: string;
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
  budgetSourceHash: string;
  eventBudget: {
    budgetId: string;
    path: string;
    revision: number;
    currency: string;
    limitMicros: number;
    chargedMicros: number;
    startsAt: number;
    endsAt: number;
    reviewHash: string;
    status: "paused";
  };
  senderDayBudget: {
    budgetId: string;
    path: string;
    revision: number;
    currency: string;
    limitMicros: number;
    chargedMicros: number;
    startsAt: number;
    endsAt: number;
    reviewHash: string;
    status: "paused";
  };
  appliedByUid: string;
  note: string;
  effect: "budgets_staged_paused_no_spending_or_dispatch_authority";
  stagesSpendingCeilings: true;
  grantsSpendingAuthority: false;
  grantsDispatchAuthority: false;
  providerContacted: false;
  workerActivated: false;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
