/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminListSalesFitQueuePayload {
  view: "ranked" | "needs_research" | "outreach_review_candidate";
  limit?: number;
  cursor?: string;
}
