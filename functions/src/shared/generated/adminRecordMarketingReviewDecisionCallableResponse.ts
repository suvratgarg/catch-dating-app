/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminRecordMarketingReviewDecisionCallableResponse {
  decisionId: string;
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
  decisionStatus:
    | "approved"
    | "needs_changes"
    | "held"
    | "rejected"
    | "export_ready";
  decisionPath: string;
}
