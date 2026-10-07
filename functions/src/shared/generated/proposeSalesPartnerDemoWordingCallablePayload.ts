/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface ProposeSalesPartnerDemoWordingCallablePayload {
  requestId: string;
  organizerId: string;
  expectedAssignmentRevision: number;
  blueprintId: string;
  expectedPreviewHash: string;
  expectedProposalRevision: number;
  wording: {
    headline: string;
    scenario: string;
    cta: string;
  };
}
