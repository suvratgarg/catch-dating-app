import {
  loadHostAnalytics,
  loadOverview,
} from "../../../shared/api/adminApi";
import type {
  AdminOverviewResponse,
  HostAnalyticsQueryPayload,
  HostAnalyticsResponse,
} from "../../../shared/types/adminTypes";

export function loadGrowthOverview(): Promise<AdminOverviewResponse> {
  return loadOverview();
}

export function loadGrowthHostAnalytics(
  payload: HostAnalyticsQueryPayload
): Promise<HostAnalyticsResponse> {
  return loadHostAnalytics(payload);
}
