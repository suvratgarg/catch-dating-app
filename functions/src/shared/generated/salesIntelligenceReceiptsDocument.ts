/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Immutable employee-scoped exact-retry receipt for private policy, evidence assessment, score, clause and manual-copy actions. Never proof of sending.
 */
export interface SalesIntelligenceReceiptDocument {
  schemaVersion: 1;
  classification: "sales_private";
  receiptId: string;
  actorUid: string;
  action:
    | "policy.save"
    | "assessment.save"
    | "clause.save"
    | "clause.review"
    | "score.snapshot"
    | "draft.record"
    | "draft.review"
    | "draft.copy";
  requestId: string;
  materialHash: string;
  result: {
    [k: string]: unknown;
  };
  createdAt: string;
}
