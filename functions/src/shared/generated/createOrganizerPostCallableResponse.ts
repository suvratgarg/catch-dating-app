/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable response returned by createOrganizerPost.
 */
export interface CreateOrganizerPostCallableResponse {
  postId: string;
  remainingWeeklyQuota: number;
  deliveryStatus: "pending" | "completed" | "partial";
  recipientCount: number;
  excludedCount: number;
  activityAvailableCount: number;
  pushAttemptedCount: number;
  pushAcceptedCount: number;
  pushFailedCount: number;
  pushUnknownCount: number;
  idempotentReplay: boolean;
}
