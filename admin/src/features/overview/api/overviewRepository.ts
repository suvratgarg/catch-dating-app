import {
  loadHostAnalytics,
  loadOverview,
} from "../../../shared/api/adminApi";
import type {
  AdminOverviewResponse,
  HostAnalyticsQueryPayload,
  HostAnalyticsResponse,
} from "../../../shared/types/adminTypes";

export function loadOverviewSnapshot(): Promise<AdminOverviewResponse> {
  return loadOverview();
}

export function loadOverviewHostAnalytics(
  payload: HostAnalyticsQueryPayload
): Promise<HostAnalyticsResponse> {
  return loadHostAnalytics(payload);
}
