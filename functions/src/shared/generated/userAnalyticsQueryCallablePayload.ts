/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by getUserAnalytics and adminGetUserAnalytics.
 */
export interface UserAnalyticsQueryCallablePayload {
  /**
   * Admin-only user scope override. getUserAnalytics always scopes to the signed-in user.
   */
  userId?: string | null;
  rangePreset?: "7d" | "30d" | "90d" | "month" | "custom";
  startDate?: string | null;
  endDate?: string | null;
  granularity?: "day" | "week" | "month";
}
