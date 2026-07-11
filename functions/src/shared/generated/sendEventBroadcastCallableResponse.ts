/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Delivery summary returned by sendEventBroadcast.
 */
export interface SendEventBroadcastCallableResponse {
  broadcastId: string;
  status: "completed" | "partial";
  recipientCount: number;
  excludedCount: number;
  activityAvailableCount: number;
  pushAttemptedCount: number;
  pushAcceptedCount: number;
  pushFailedCount: number;
  pushUnknownCount: number;
  idempotentReplay: boolean;
}
