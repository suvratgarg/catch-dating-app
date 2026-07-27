/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by adminRecordEventIntakeReviewDecision. This records a manual admin decision for private event-intake artifacts without publishing marketing content or creating canonical events.
 */
export interface AdminRecordEventIntakeReviewDecisionCallablePayload {
  targetType:
    | "source_profile"
    | "query_template"
    | "run_plan"
    | "source_result"
    | "event_candidate";
  targetId: string;
  decision: "approve" | "needs_changes" | "hold" | "reject";
  runId?: string | null;
  note: string;
  /**
   * Changed fields only. Each entry freezes the reviewed before and after values so extractor-learning and audit consumers can distinguish a correction from a whole-record resubmission.
   */
  edits?: {
    [k: string]: {
      before: unknown;
      after: unknown;
    };
  };
  checklist: {
    sourceReviewed: boolean;
    dateReviewed: boolean;
    venueReviewed: boolean;
    copyReviewed: boolean;
    rightsReviewed: boolean;
    noCatchHostingImplied: boolean;
  };
}
