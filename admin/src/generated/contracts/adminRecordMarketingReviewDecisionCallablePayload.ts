/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminRecordMarketingReviewDecisionCallablePayload {
  targetType:
    | "source_profile"
    | "query_template"
    | "run_plan"
    | "source_result"
    | "event_candidate"
    | "recommendation_item"
    | "recommendation_set"
    | "content_draft";
  targetId: string;
  decision: "approve" | "needs_changes" | "hold" | "reject" | "export_ready";
  runId?: string | null;
  note: string;
  edits?: {
    [k: string]: unknown;
  };
  checklist?: {
    sourceReviewed?: boolean;
    dateReviewed?: boolean;
    venueReviewed?: boolean;
    copyReviewed?: boolean;
    rightsReviewed?: boolean;
    noCatchHostingImplied?: boolean;
  };
}
