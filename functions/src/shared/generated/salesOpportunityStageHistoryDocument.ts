/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Append-only private stage movement with explicit loss/reopen reason.
 */
export interface SalesOpportunityStageHistoryDocument {
  schemaVersion: 1;
  classification: "sales_private";
  historyId: string;
  organizerId: string;
  opportunityId: string;
  fromStage: string | null;
  toStage: string;
  reason: string | null;
  actorUid: string;
  changedAt: string;
}
