/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Safe result of one provider roster reconciliation.
 */
export interface SyncOrganizerProviderEventCallableResponse {
  runId: string;
  status: "completed" | "partial" | "failed";
  pageCount: number;
  receivedCount: number;
  createdCount: number;
  updatedCount: number;
  skippedCount: number;
  truncated: boolean;
  replayed: boolean;
}
