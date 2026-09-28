/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminReviewSalesPrivacyPlanResponse {
  plan: {
    planId: string;
    organizerId: string;
    policyHash: string;
    inventoryHash: string;
    cursor: number;
    itemCount: number;
    retainedCount: number;
    unresolvedCount: number;
    /**
     * @maxItems 240
     */
    blockers: {
      code: string;
      fingerprint: string;
    }[];
    status: "reviewed" | "processing" | "internal_processed_with_unresolved";
  };
}
