export type FitQueueView = "ranked" | "needs_research" |
  "outreach_review_candidate";

export interface FitQueueEntry {
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
  researchStatus: string;
  name: string;
  city: string | null;
  assignedOwnerUid: string | null;
  expiresAt: string | null;
  evaluatedAt: string;
}
export interface FitQueuePage {
  rows: FitQueueEntry[];
  nextCursor: string | null;
  generation: number;
  policyRevision: number;
  qualificationPolicyHash: string | null;
  omittedExpiredInPage: number;
}
export interface FitRefreshResult {
  entry: FitQueueEntry;
  receipt: {requestId: string; sourceHash: string};
}
export interface FitBatchResult {
  rows: Array<{organizerId: string;
    result: "refreshed" | "needs_review";
    sourceHash: string | null; reason: string | null}>;
  nextCursor: string | null;
}
export interface FitQueueApi {
  list(view: FitQueueView, cursor?: string): Promise<FitQueuePage>;
  refresh(input: {organizerId: string; requestId: string}):
    Promise<FitRefreshResult>;
  refreshBatch(input: {requestId: string; cursor?: string; limit: number}):
    Promise<FitBatchResult>;
}
