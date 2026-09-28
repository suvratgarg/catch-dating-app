/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-inventoried, exact-source cleanup plan. Paths are private and never returned in owner previews.
 */
export interface SalesPrivacyPlan {
  schemaVersion: 1;
  classification: "sales_private";
  planId: string;
  requestId: string;
  organizerId: string;
  restrictionRevision: number;
  policyHash: string;
  inventoryHash: string;
  /**
   * @maxItems 240
   */
  items: {
    path: string;
    contentHash: string;
    disposition: "delete" | "retain_finance" | "retain_audit";
  }[];
  /**
   * @maxItems 240
   */
  blockers: {
    code: string;
    fingerprint: string;
  }[];
  cursor: number;
  status: "reviewed" | "processing" | "internal_processed_with_unresolved";
  reviewedByUid: string;
  reviewedAt: string;
  updatedAt: string;
}
