/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Immutable reviewed-source fit snapshot. Unknown or disputed factors yield a null score and unranked priority.
 */
export interface SalesIntelligenceScoreSnapshotDocument {
  schemaVersion: 1;
  classification: "sales_private";
  snapshotId: string;
  organizerId: string;
  accountRevision: number;
  policyId: string;
  policyRevision: number;
  policyVersion: string;
  sourceHash: string;
  status: "complete" | "needs_research" | "review_required";
  score: number | null;
  priority: "high" | "medium" | "low" | "unranked";
  /**
   * @minItems 7
   * @maxItems 7
   */
  factors: {
    factorId: string;
    state: "known" | "unknown" | "disputed";
    value: number | null;
    /**
     * @maxItems 8
     */
    evidenceIds: string[];
    reason: string | null;
  }[];
  evaluatedAt: string;
}
