/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Latest admin/product policy-gap review decision stored at organizerPolicyGapReviewDecisions/{decisionId}. These decisions are review state only and do not enable organizer crawls, provider lookups, event imports, defaults, or naming migrations.
 */
export interface OrganizerPolicyGapReviewDecisionDocument {
  schemaVersion: 1;
  decisionId: string;
  gapId: string;
  decision: "accept" | "hold" | "reject";
  decisionStatus: "accepted" | "held" | "rejected";
  /**
   * @maxItems 20
   */
  requiredInputsReviewed: string[];
  checklist: {
    requiredInputsReviewed: boolean;
    costAndSafetyReviewed: boolean;
    implementationOwnerReviewed: boolean;
    behaviorStillDisabledAcknowledged: boolean;
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
  operationalState: "blocked_until_policy_encoded" | "not_approved";
}
