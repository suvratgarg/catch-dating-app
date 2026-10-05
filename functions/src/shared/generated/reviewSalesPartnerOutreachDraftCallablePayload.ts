/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface ReviewSalesPartnerOutreachDraftCallablePayload {
  requestId: string;
  organizerId: string;
  expectedAssignmentRevision: number;
  draftId: string;
  expectedContentHash: string;
  factualValidity: "verified";
  tone: "approved";
  channelReadiness: "manual_copy_only";
}
