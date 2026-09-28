/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private current-fit projection. Only the source-bound, unexpired row may appear in a queue; this is never send authority.
 */
export interface SalesFitQueueEntryDocument {
  schemaVersion: 1;
  classification: "sales_private";
  organizerId: string;
  policyId: string;
  policyRevision: number;
  policyVersion: string;
  sourceHash: string;
  accountRevision: number;
  qualificationPolicyHash: string | null;
  status: "complete" | "needs_research" | "review_required";
  score: number | null;
  priority: "high" | "medium" | "low" | "unranked";
  eligibleForOutreachReview: boolean;
  suppressionStatus: "clear" | "held" | "suppressed";
  duplicateReviewRequired: boolean;
  researchStatus:
    | "new"
    | "needs_research"
    | "ready_for_review"
    | "qualified"
    | "benchmark_only"
    | "no_fit"
    | "archived";
  name: string;
  city: string | null;
  assignedOwnerUid: string | null;
  expiresAt: string | null;
  evaluatedAt: string;
  qualificationExpiresAt: string | null;
}
