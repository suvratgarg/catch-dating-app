/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Latest admin review decision stored at organizerIntakeReviewDecisions/{entityId}. Raw scrape/search evidence is not stored here.
 */
export interface OrganizerIntakeReviewDecisionDocument {
  schemaVersion: 1;
  entityId: string;
  decision: "approve_public" | "hold" | "suppress";
  decisionStatus: "approved_public" | "held" | "suppressed";
  appVisibility: "hidden" | "discoverable";
  checklist: {
    identityReviewed: boolean;
    surfaceInventoryReviewed: boolean;
    ownerSafeCopyReviewed: boolean;
    marketScopeReviewed: boolean;
    mediaRightsReviewed: boolean;
    crawlDisabledReviewed: boolean;
    /**
     * True when the reviewer explicitly inspected manual reports that have no local raw artifact. Raw evidence remains outside Firestore; projection replay decides when this acknowledgement is required.
     */
    manualReportsReviewed?: boolean;
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
  projectionState: "pending_static_generation" | "not_projectable";
}
