import {
  loadHostAnalytics,
  loadOverview,
} from "../../../shared/api/adminApi";
import type {
  AdminOverviewResponse,
  HostAnalyticsQueryPayload,
  HostAnalyticsResponse,
} from "../../../shared/types/adminTypes";

export interface GrowthKpiSnapshot {
  loadedAt: string;
  overview: AdminOverviewResponse;
  hostAnalytics: HostAnalyticsResponse;
}

export async function loadGrowthKpiSnapshot(
  payload: HostAnalyticsQueryPayload
): Promise<GrowthKpiSnapshot> {
  const [overview, hostAnalytics] = await Promise.all([
    loadOverview(),
    loadHostAnalytics(payload),
  ]);
  return {
    loadedAt: new Date().toISOString(),
    overview,
    hostAnalytics,
  };
}
