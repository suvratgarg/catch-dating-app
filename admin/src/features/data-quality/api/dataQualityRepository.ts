import {
  loadEventIntakeDashboard,
  loadEventSupplyReadiness,
  loadHostAnalytics,
  loadMarketingOpsBridge,
  loadOverview,
} from "../../../shared/api/adminApi";
import type {
  AdminGetEventSupplyReadinessResponse,
  AdminOverviewResponse,
  EventIntakeBridge,
  HostAnalyticsResponse,
  MarketingOpsBridge,
} from "../../../shared/types/adminTypes";

export function loadDataQualityOverview(): Promise<AdminOverviewResponse> {
  return loadOverview();
}

export function loadDataQualityHostAnalytics(): Promise<HostAnalyticsResponse> {
  return loadHostAnalytics({rangePreset: "30d", granularity: "day"});
}

export async function loadDataQualityMarketingBridge(): Promise<MarketingOpsBridge> {
  return (await loadMarketingOpsBridge()).bridge;
}

export async function loadDataQualityEventIntakeBridge(): Promise<EventIntakeBridge> {
  return (await loadEventIntakeDashboard()).bridge;
}

export function loadDataQualityEventSupplyReadiness():
  Promise<AdminGetEventSupplyReadinessResponse> {
  return loadEventSupplyReadiness();
}
