/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Latest admin review decision stored at eventIntakeReviewDecisions/{decisionId}. Source artifacts, marketing content, imported events, and canonical events are not stored here.
 */
export interface EventIntakeReviewDecisionDocument {
  schemaVersion: 1;
  decisionId: string;
  targetType:
    | "source_profile"
    | "query_template"
    | "run_plan"
    | "source_result"
    | "event_candidate";
  targetId: string;
  decision: "approve" | "needs_changes" | "hold" | "reject";
  decisionStatus: "approved" | "needs_changes" | "held" | "rejected";
  runId: string | null;
  note: string;
  checklist: {
    sourceReviewed: boolean;
    dateReviewed: boolean;
    venueReviewed: boolean;
    copyReviewed: boolean;
    rightsReviewed: boolean;
    noCatchHostingImplied: boolean;
  };
  edits: {
    [k: string]: unknown;
  };
  reviewedByUid: string;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  reviewedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  effect: "decision_only_no_publish";
}
