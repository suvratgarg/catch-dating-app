import {useCallback, useEffect, useMemo, useState} from "react";
import type {
  AdminOverviewResponse,
  DataMode,
  HostAnalyticsQueryPayload,
  HostAnalyticsResponse,
} from "../../../shared/types/adminTypes";
import {
  initialOverviewHostAnalytics,
  initialOverviewSnapshot,
  loadOverviewHostAnalytics,
  loadOverviewSnapshot,
} from "../api/overviewRepository";

export type OverviewAnalyticsRangePreset = NonNullable<
  HostAnalyticsQueryPayload["rangePreset"]
>;
export type OverviewAnalyticsGranularity = NonNullable<
  HostAnalyticsQueryPayload["granularity"]
>;

const hostAnalyticsRoles = [
  "adminOwner",
  "analyticsViewer",
] as const;

export function useOverviewController({
  adminRoles,
  isSessionReady,
  mode,
  onError,
  onNotice,
}: {
  adminRoles: string[];
  isSessionReady: boolean;
  mode: DataMode;
  onError: (message: string | null) => void;
  onNotice: (message: string | null) => void;
}) {
  const [analyticsRangePreset, setAnalyticsRangePreset] =
    useState<OverviewAnalyticsRangePreset>("30d");
  const [analyticsGranularity, setAnalyticsGranularity] =
    useState<OverviewAnalyticsGranularity>("day");
  const [analyticsStartDate, setAnalyticsStartDate] =
    useState(defaultAnalyticsDate(29));
  const [analyticsEndDate, setAnalyticsEndDate] =
    useState(defaultAnalyticsDate(0));
  const [analyticsClubId, setAnalyticsClubId] = useState("");
  const [analyticsEventId, setAnalyticsEventId] = useState("");
  const [overview, setOverview] =
    useState<AdminOverviewResponse>(initialOverviewSnapshot);
  const [hostAnalytics, setHostAnalytics] =
    useState<HostAnalyticsResponse>(initialOverviewHostAnalytics);
  const [isLoading, setIsLoading] = useState(false);

  const analyticsPayload = useMemo(
    () => buildHostAnalyticsPayload({
      clubId: analyticsClubId,
      eventId: analyticsEventId,
      granularity: analyticsGranularity,
      rangePreset: analyticsRangePreset,
      startDate: analyticsStartDate,
      endDate: analyticsEndDate,
    }),
    [
      analyticsClubId,
      analyticsEndDate,
      analyticsEventId,
      analyticsGranularity,
      analyticsRangePreset,
      analyticsStartDate,
    ]
  );
  const canLoadAnalytics = mode === "sample" ||
    hasAnyAdminRole(adminRoles, hostAnalyticsRoles);

  const refresh = useCallback(async () => {
    setIsLoading(true);
    onError(null);
    try {
      const overviewPromise = loadOverviewSnapshot();
      const hostAnalyticsPromise = canLoadAnalytics ?
        loadOverviewHostAnalytics(analyticsPayload) :
        Promise.resolve(restrictedHostAnalyticsResponse(analyticsPayload));
      const [nextOverview, nextHostAnalytics] = await Promise.all([
        overviewPromise,
        hostAnalyticsPromise,
      ]);
      setOverview(nextOverview);
      setHostAnalytics(nextHostAnalytics);
    } catch (loadError) {
      onError(
        loadError instanceof Error ?
          loadError.message :
          "Unable to load admin overview."
      );
    } finally {
      setIsLoading(false);
    }
  }, [analyticsPayload, canLoadAnalytics, onError]);

  useEffect(() => {
    if (!isSessionReady) return;
    void refresh();
  }, [isSessionReady, refresh]);

  const clearAnalyticsScope = useCallback(() => {
    setAnalyticsClubId("");
    setAnalyticsEventId("");
  }, []);

  return {
    analyticsClubId,
    analyticsEndDate,
    analyticsEventId,
    analyticsGranularity,
    analyticsRangePreset,
    analyticsStartDate,
    hostAnalytics,
    isLoading,
    overview,
    clearAnalyticsScope,
    refresh,
    setAnalyticsClubId,
    setAnalyticsEndDate,
    setAnalyticsEventId,
    setAnalyticsGranularity,
    setAnalyticsRangePreset,
    setAnalyticsStartDate,
  };
}

function buildHostAnalyticsPayload({
  clubId,
  endDate,
  eventId,
  granularity,
  rangePreset,
  startDate,
}: {
  clubId: string;
  endDate: string;
  eventId: string;
  granularity: OverviewAnalyticsGranularity;
  rangePreset: OverviewAnalyticsRangePreset;
  startDate: string;
}): HostAnalyticsQueryPayload {
  const isCustom = rangePreset === "custom";
  return {
    clubId: clubId.trim() || null,
    eventId: eventId.trim() || null,
    rangePreset,
    startDate: isCustom ? startDate : null,
    endDate: isCustom ? endDate : null,
    granularity,
  };
}

function hasAnyAdminRole(
  roles: string[],
  allowedRoles: readonly string[]
): boolean {
  return allowedRoles.some((role) => roles.includes(role));
}

function restrictedHostAnalyticsResponse(
  payload: HostAnalyticsQueryPayload
): HostAnalyticsResponse {
  const generatedAt = new Date().toISOString();
  return {
    generatedAt,
    timezone: "UTC",
    range: {
      startDate: payload.startDate ?? defaultAnalyticsDate(29),
      endDate: payload.endDate ?? defaultAnalyticsDate(0),
      granularity: payload.granularity ?? "day",
      preset: payload.rangePreset ?? null,
    },
    scope: {
      clubIds: [],
      eventIds: [],
      clubName: null,
      eventTitle: null,
    },
    summaryCards: [],
    trend: [],
    topEvents: [],
    reviewSummary: {
      newReviews: 0,
      publishedReviews: 0,
      verifiedReviews: 0,
      publicReviews: 0,
      ownerResponseCount: 0,
      averageRating: 0,
    },
    discoverySummary: {
      listingViews: 0,
      searchAppearances: 0,
      eventViews: 0,
      organizerSaves: 0,
      eventSaves: 0,
      contactClicks: 0,
      claimClicks: 0,
      outboundClicks: 0,
    },
    dataQuality: [{
      id: "host-analytics-role-restricted",
      state: "missing",
      detail:
        "Host analytics are hidden for this admin role; backend callable access is role-scoped.",
      owner: "Admin platform",
      runbook: "admin/src/features/overview/controllers/useOverviewController.ts",
      nextAction:
        "Grant an analytics-capable admin role before using host analytics signals.",
    }],
  };
}

function defaultAnalyticsDate(daysAgo: number): string {
  const date = new Date();
  date.setUTCDate(date.getUTCDate() - daysAgo);
  return date.toISOString().slice(0, 10);
}
