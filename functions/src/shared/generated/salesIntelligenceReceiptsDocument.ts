/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Immutable actor-scoped exact-retry receipt for private employee intelligence and assignment-bound partner composition actions. Never proof of sending.
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
    | "draft.copy"
    | "partner.draft.record"
    | "partner.draft.review"
    | "partner.draft.copy"
    | "partner.draft.manual_send"
    | "partner.draft.edit";
  requestId: string;
  materialHash: string;
  result: {
    [k: string]: unknown;
  };
  createdAt: string;
}
