/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-only reviewed eligibility record for showing one member in Cross Paths. It stores coarse readiness reasons and a profile fingerprint, never an attractiveness score.
 */
export interface CrossPathsShowcaseEligibilityDocument {
  status: "eligible" | "needsReview" | "paused";
  /**
   * @maxItems 12
   */
  reasonCodes: (
    | "insufficient_photos"
    | "incomplete_prompts"
    | "missing_relationship_goal"
    | "broken_media"
    | "photo_moderation_pending"
    | "photo_moderation_rejected"
    | "public_profile_missing"
    | "profile_changed"
    | "reviewer_hold"
    | "manual_pause"
  )[];
  ruleVersion: number;
  reviewVersion: number;
  profileFingerprint: string;
  reviewChecklist: {
    primaryPortraitClear: boolean;
    profileRepresentsCurrentMember: boolean;
    showcasePolicyReviewed: boolean;
  };
  reviewNote: string;
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
}
