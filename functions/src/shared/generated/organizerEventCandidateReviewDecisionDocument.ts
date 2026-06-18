/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Latest admin event-candidate review decision stored at organizerEventCandidateReviewDecisions/{decisionId}. Raw provider event evidence and imported events are not stored here.
 */
export interface OrganizerEventCandidateReviewDecisionDocument {
  schemaVersion: 1;
  decisionId: string;
  candidateId: string;
  decision: "approve_for_import" | "hold" | "reject";
  decisionStatus: "approved_for_import" | "held" | "rejected";
  checklist: {
    identityReviewed: boolean;
    sourceEventReviewed: boolean;
    timeReviewed: boolean;
    locationReviewed: boolean;
    dedupeReviewed: boolean;
    ownerSafeCopyReviewed: boolean;
    importPolicyAcknowledged: boolean;
  };
  note: string;
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
  importState: "blocked_by_policy" | "not_importable" | "pending_import";
}
