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

export function loadGrowthOverview(): Promise<AdminOverviewResponse> {
  return loadOverview();
}

export function loadGrowthHostAnalytics(
  payload: HostAnalyticsQueryPayload
): Promise<HostAnalyticsResponse> {
  return loadHostAnalytics(payload);
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
