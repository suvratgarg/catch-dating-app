import {
  loadHostAnalytics,
  loadOverview,
} from "../../../shared/api/adminApi";
import type {
  AdminOverviewResponse,
  HostAnalyticsResponse,
} from "../../../shared/types/adminTypes";

export interface FinanceOpsSnapshot {
  loadedAt: string;
  overview: AdminOverviewResponse;
  hostAnalytics: HostAnalyticsResponse;
}

export async function loadFinanceOpsSnapshot():
  Promise<FinanceOpsSnapshot> {
  const [overview, hostAnalytics] = await Promise.all([
    loadOverview(),
    loadHostAnalytics({rangePreset: "30d", granularity: "week"}),
  ]);
  return {
    loadedAt: new Date().toISOString(),
    overview,
    hostAnalytics,
  };
}
