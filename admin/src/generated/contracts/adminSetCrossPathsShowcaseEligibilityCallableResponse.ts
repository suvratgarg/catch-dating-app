/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Validated result of one audited Cross Paths showcase eligibility decision.
 */
export interface AdminSetCrossPathsShowcaseEligibilityCallableResponse {
  uid: string;
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
  profileFingerprint: string;
  ruleVersion: number;
  reviewVersion: number;
  reviewedAt: string;
}
