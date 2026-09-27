/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Append-only exact-version approval or reviewed terms acceptance; not a receipt.
 */
export interface SalesCommercialDecisionsDocument {
  schemaVersion: 1;
  classification: "sales_private";
  decisionId: string;
  organizerId: string;
  opportunityId: string;
  quoteId: string | null;
  termVersion: number | null;
  termsHash: string;
  kind: "quote_approved" | "terms_acceptance_reviewed";
  evidence: {
    evidenceId: string;
    sourceRef: string;
    contentHash: string;
    observedAt: string;
  };
  approvedDecisionId: string | null;
  actorUid: string;
  decidedAt: string;
  paymentStatus: "unknown";
}
