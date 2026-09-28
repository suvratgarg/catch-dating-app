/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminGetSalesOutreachDraftJobResponse {
  status: "running" | "completed" | "failed";
  result: {
    draftId: string;
    contentHash: string;
  } | null;
  failure: string | null;
  retryAfterSeconds: number | null;
}
