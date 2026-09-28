/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminReviewSalesIntelligenceClauseRequest {
  requestId: string;
  clauseId: string;
  expectedRevision: number;
  decision: "approve" | "withdraw";
}
