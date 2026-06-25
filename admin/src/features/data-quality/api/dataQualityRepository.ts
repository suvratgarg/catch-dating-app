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

export interface DataQualitySnapshot {
  generatedAt: string;
  overview: AdminOverviewResponse;
  hostAnalytics: HostAnalyticsResponse;
  marketingBridge: MarketingOpsBridge;
  eventIntakeBridge: EventIntakeBridge;
  eventSupplyReadiness: AdminGetEventSupplyReadinessResponse;
}

export async function loadDataQualitySnapshot():
  Promise<DataQualitySnapshot> {
  const [
    overview,
    hostAnalytics,
    marketingOps,
    eventIntakeDashboard,
    eventSupplyReadiness,
  ] = await Promise.all([
    loadOverview(),
    loadHostAnalytics({rangePreset: "30d", granularity: "day"}),
    loadMarketingOpsBridge(),
    loadEventIntakeDashboard(),
    loadEventSupplyReadiness(),
  ]);
  return {
    generatedAt: new Date().toISOString(),
    overview,
    hostAnalytics,
    marketingBridge: marketingOps.bridge,
    eventIntakeBridge: eventIntakeDashboard.bridge,
    eventSupplyReadiness,
  };
}
