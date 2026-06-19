/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by getHostAnalytics and adminGetHostAnalytics.
 */
export interface HostAnalyticsQueryCallablePayload {
  clubId?: string | null;
  eventId?: string | null;
  rangePreset?: "7d" | "30d" | "90d" | "month" | "custom";
  startDate?: string | null;
  endDate?: string | null;
  granularity?: "day" | "week" | "month";
}
