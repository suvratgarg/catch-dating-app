/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Immutable request receipt for an event-messaging budget decision. It preserves exact replay without granting spending authority.
 */
export interface EventMessagingBudgetDecisionReceiptDocument {
  schemaVersion: 1;
  receiptId: string;
  decisionId: string;
  requestId: string;
  requestHash: string;
  revision: number;
  decisionStatus: "approved" | "held" | "rejected";
  decisionPath: string;
  effect: "decision_only_no_spending_authority";
  grantsSpendingAuthority: false;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
