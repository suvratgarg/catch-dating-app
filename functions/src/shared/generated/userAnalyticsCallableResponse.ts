/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * User-safe profile and connection analytics response. Internal scoring columns stay in BigQuery and are intentionally not exposed here.
 */
export interface UserAnalyticsCallableResponse {
  generatedAt: string;
  timezone: string;
  range: {
    startDate: string;
    endDate: string;
    granularity: "day" | "week" | "month";
    preset?: string | null;
  };
  scope: {
    userId: string;
  };
  summaryCards: {
    id: string;
    label: string;
    value: number;
    unit: "count" | "percent" | "duration_seconds";
    status: "ready" | "partial" | "missing";
    caption?: string | null;
  }[];
  trend: {
    periodStart: string;
    periodEnd: string;
    metrics: {
      [k: string]: number;
    };
  }[];
  connectionSummary: {
    outgoingLikes: number;
    incomingLikes: number;
    privateInterestReceived: number;
    mutualCatches: number;
    chatsStarted: number;
    chatMessagesSent: number;
    followThroughRate: number;
    eventsAttended: number;
  };
  profileSummary: {
    profileViews: number;
    uniqueViewers: number;
    profileDwellSeconds: number;
    photoImpressions: number;
    topPhotoId: string | null;
    activeMinutes: number;
  };
  /**
   * @maxItems 4
   */
  coachingTipRefs: {
    id: string;
    copyKey: string;
    priority: number;
    metricIds: string[];
  }[];
  dataQuality: {
    id: string;
    state: "ok" | "partial" | "missing";
    detail: string;
  }[];
}
