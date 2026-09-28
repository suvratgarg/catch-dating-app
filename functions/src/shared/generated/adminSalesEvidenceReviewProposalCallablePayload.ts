/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminSalesEvidenceReviewProposalCallablePayload {
  organizerId: string;
  requestId: string;
  proposalId: string;
  expectedRevision: number;
  decision: "accept" | "reject";
  reason: string;
}
