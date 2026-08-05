/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload for an audited human Cross Paths showcase eligibility decision.
 */
export interface AdminSetCrossPathsShowcaseEligibilityCallablePayload {
  uid: string;
  status: "eligible" | "needsReview" | "paused";
  reviewChecklist: {
    primaryPortraitClear: boolean;
    profileRepresentsCurrentMember: boolean;
    showcasePolicyReviewed: boolean;
  };
  reviewNote: string;
}
