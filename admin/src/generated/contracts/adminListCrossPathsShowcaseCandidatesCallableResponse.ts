/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Bounded admin-safe projection of public profiles and their server-only Cross Paths showcase review state.
 */
export interface AdminListCrossPathsShowcaseCandidatesCallableResponse {
  schemaVersion: 1;
  generatedAt: string;
  /**
   * @maxItems 50
   */
  candidates: {
    uid: string;
    name: string | null;
    age: number | null;
    gender: string | null;
    city: string | null;
    /**
     * @maxItems 6
     */
    photoUrls: string[];
    /**
     * @maxItems 3
     */
    promptAnswers: {
      prompt: string;
      answer: string;
    }[];
    relationshipGoal: string | null;
    automaticStatus: "ready" | "blocked";
    /**
     * @maxItems 7
     */
    automaticReasonCodes: (
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
    storedStatus: "eligible" | "needsReview" | "paused" | null;
    effectiveStatus: "eligible" | "needsReview" | "paused";
    /**
     * @maxItems 12
     */
    effectiveReasonCodes: (
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
    reviewedByUid: string | null;
    reviewedAt: string | null;
    reviewNote: string | null;
  }[];
  nextCursor: string | null;
}
