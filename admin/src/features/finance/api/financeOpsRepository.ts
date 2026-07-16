import {
  loadHostAnalytics,
  loadOverview,
} from "../../../shared/api/adminApi";
import type {
  AdminOverviewResponse,
  HostAnalyticsResponse,
} from "../../../shared/types/adminTypes";

export function loadFinanceOverview(): Promise<AdminOverviewResponse> {
  return loadOverview();
}

export function loadFinanceHostAnalytics(): Promise<HostAnalyticsResponse> {
  return loadHostAnalytics({rangePreset: "30d", granularity: "week"});
}
