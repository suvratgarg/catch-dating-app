/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload for a bounded, role-gated Cross Paths showcase review queue.
 */
export interface AdminListCrossPathsShowcaseCandidatesCallablePayload {
  uid?: string | null;
  status?: "all" | "eligible" | "needsReview" | "paused" | null;
  cursor?: string | null;
  limit?: number;
}
