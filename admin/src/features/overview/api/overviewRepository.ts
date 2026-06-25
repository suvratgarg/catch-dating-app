import {
  loadHostAnalytics,
  loadOverview,
} from "../../../shared/api/adminApi";
import {
  sampleHostAnalytics,
  sampleOverview,
} from "../../../shared/api/sampleData";
import type {
  AdminOverviewResponse,
  HostAnalyticsQueryPayload,
  HostAnalyticsResponse,
} from "../../../shared/types/adminTypes";

export function initialOverviewSnapshot(): AdminOverviewResponse {
  return sampleOverview;
}

export function initialOverviewHostAnalytics(): HostAnalyticsResponse {
  return sampleHostAnalytics;
}

export function loadOverviewSnapshot(): Promise<AdminOverviewResponse> {
  return loadOverview();
}

export function loadOverviewHostAnalytics(
  payload: HostAnalyticsQueryPayload
): Promise<HostAnalyticsResponse> {
  return loadHostAnalytics(payload);
}
