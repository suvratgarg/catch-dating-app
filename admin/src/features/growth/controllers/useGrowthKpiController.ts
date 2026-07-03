import {useQuery} from "@tanstack/react-query";
import {useCallback, useEffect, useMemo, useState} from "react";
import type {
  HostAnalyticsMetricCard,
  HostAnalyticsTrendPoint,
} from "../../../shared/types/adminTypes";
import {adminQueryKeys} from "../../../shared/query/queryKeys";
import {loadGrowthKpiSnapshot} from "../api/growthKpiRepository";

export type GrowthStage =
  | "all"
  | "acquisition"
  | "supply"
  | "conversion"
  | "marketplace";
export type GrowthRangePreset = "7d" | "30d" | "90d" | "month";
export type GrowthSignalStatus = "ready" | "partial" | "missing";

export interface GrowthSignalRow {
  id: string;
  stage: Exclude<GrowthStage, "all">;
  label: string;
  value: number;
  unit: "count" | "percent" | "money_minor" | "rating";
  status: GrowthSignalStatus;
  source: string;
  detail: string;
}

export interface GrowthMetrics {
  signals: number;
  watch: number;
  signupsThisWeek: number;
  bookings: number;
}

export interface GrowthKpiController {
  filteredRows: GrowthSignalRow[];
  isLoading: boolean;
  loadedAt: string | null;
  metrics: GrowthMetrics;
  query: string;
  rangePreset: GrowthRangePreset;
  rows: GrowthSignalRow[];
  selected: GrowthSignalRow | null;
  stageFilter: GrowthStage;
  trend: HostAnalyticsTrendPoint[];
  refresh: () => Promise<boolean>;
  select: (row: GrowthSignalRow) => void;
  setQuery: (value: string) => void;
  setRangePreset: (value: GrowthRangePreset) => void;
  setStageFilter: (value: GrowthStage) => void;
}

export function useGrowthKpiController({
  onError,
}: {
  onError: (message: string | null) => void;
}): GrowthKpiController {
  const [rangePreset, setRangePreset] =
    useState<GrowthRangePreset>("30d");
  const [stageFilter, setStageFilter] = useState<GrowthStage>("all");
  const [query, setQuery] = useState("");
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const granularity = rangePreset === "7d" ? "day" : "week";
  const snapshotQuery = useQuery({
    queryKey: adminQueryKeys.growth.kpis(rangePreset, granularity),
    queryFn: () => loadGrowthKpiSnapshot({
      rangePreset,
      granularity,
    }),
    placeholderData: (previousData) => previousData,
  });
  const rows = useMemo(
    () => snapshotQuery.data ? buildGrowthRows(snapshotQuery.data) : [],
    [snapshotQuery.data]
  );
  const trend = snapshotQuery.data?.hostAnalytics.trend ?? [];
  const loadedAt = snapshotQuery.data?.loadedAt ?? null;

  const refresh = useCallback(async () => {
    const result = await snapshotQuery.refetch();
    if (result.error) {
      onError(messageFromError(result.error, "Unable to load growth KPIs."));
      return false;
    }
    onError(null);
    return true;
  }, [onError, snapshotQuery]);

  useEffect(() => {
    if (snapshotQuery.isError) {
      onError(messageFromError(
        snapshotQuery.error,
        "Unable to load growth KPIs."
      ));
      return;
    }
    if (snapshotQuery.isSuccess) onError(null);
  }, [
    onError,
    snapshotQuery.error,
    snapshotQuery.isError,
    snapshotQuery.isSuccess,
  ]);

  useEffect(() => {
    setSelectedId((current) => {
      if (current && rows.some((row) => row.id === current)) return current;
      return rows.find((row) => row.status !== "ready")?.id ??
        rows[0]?.id ??
        null;
    });
  }, [rows]);

  const filteredRows = useMemo(
    () => filterRows(rows, stageFilter, query),
    [query, rows, stageFilter]
  );
  const metrics = useMemo(() => growthMetrics(rows), [rows]);
  const selected = useMemo(
    () => rows.find((row) => row.id === selectedId) ?? null,
    [rows, selectedId]
  );

  const select = useCallback((row: GrowthSignalRow) => {
    setSelectedId(row.id);
    onError(null);
  }, [onError]);

  return {
    filteredRows,
    isLoading: snapshotQuery.isPending || snapshotQuery.isFetching,
    loadedAt,
    metrics,
    query,
    rangePreset,
    rows,
    selected,
    stageFilter,
    trend,
    refresh,
    select,
    setQuery,
    setRangePreset,
    setStageFilter,
  };
}

function buildGrowthRows(snapshot: Awaited<
  ReturnType<typeof loadGrowthKpiSnapshot>
>): GrowthSignalRow[] {
  const overviewMetric = (id: string) =>
    snapshot.overview.metrics.find((item) => item.id === id);
  const hostMetric = (id: string) =>
    snapshot.hostAnalytics.summaryCards.find((item) => item.id === id);
  const discovery = snapshot.hostAnalytics.discoverySummary;
  return [
    overviewSignal("signupsToday", "acquisition", overviewMetric,
      "New waitlist/account demand today."),
    overviewSignal("signupsThisWeek", "acquisition", overviewMetric,
      "Launch demand created this week."),
    overviewSignal("completedProfiles", "acquisition", overviewMetric,
      "Users far enough through onboarding to be useful supply/demand."),
    overviewSignal("pendingClubClaims", "supply", overviewMetric,
      "Organizer claim demand waiting for review."),
    overviewSignal("activeHosts", "supply", overviewMetric,
      "Organizer accounts currently active."),
    overviewSignal("activeEvents", "supply", overviewMetric,
      "Canonical app events currently active."),
    hostSignal("bookings", "conversion", hostMetric),
    hostSignal("attendanceRate", "conversion", hostMetric),
    hostSignal("checkoutConversionRate", "conversion", hostMetric),
    hostSignal("checkoutDropoff", "conversion", hostMetric),
    hostSignal("connections", "marketplace", hostMetric),
    discoverySignal("eventSaves", "marketplace", discovery.eventSaves,
      "Event saves captured in discovery summary."),
    discoverySignal("claimClicks", "marketplace", discovery.claimClicks,
      "Organizer claim intent captured from public pages."),
  ].filter((row): row is GrowthSignalRow => row !== null);
}

function overviewSignal(
  id: string,
  stage: Exclude<GrowthStage, "all">,
  metric: (id: string) => {label: string; value: number} | undefined,
  detail: string
): GrowthSignalRow | null {
  const item = metric(id);
  if (!item) return null;
  return {
    id,
    stage,
    label: item.label,
    value: item.value,
    unit: "count",
    status: "ready",
    source: "adminGetOverview",
    detail,
  };
}

function hostSignal(
  id: string,
  stage: Exclude<GrowthStage, "all">,
  metric: (id: string) => HostAnalyticsMetricCard | undefined
): GrowthSignalRow | null {
  const item = metric(id);
  if (!item) return null;
  return {
    id,
    stage,
    label: item.label,
    value: item.value,
    unit: item.unit,
    status: item.status,
    source: "adminGetHostAnalytics",
    detail: item.caption ?? "Host analytics summary card.",
  };
}

function discoverySignal(
  id: string,
  stage: Exclude<GrowthStage, "all">,
  value: number,
  detail: string
): GrowthSignalRow {
  return {
    id,
    stage,
    label: readableId(id),
    value,
    unit: "count",
    status: value > 0 ? "ready" : "partial",
    source: "adminGetHostAnalytics.discoverySummary",
    detail,
  };
}

function filterRows(
  rows: GrowthSignalRow[],
  stageFilter: GrowthStage,
  query: string
): GrowthSignalRow[] {
  const tokens = query.trim().toLowerCase().split(/\s+/u).filter(Boolean);
  return rows.filter((row) => {
    if (stageFilter !== "all" && row.stage !== stageFilter) return false;
    if (tokens.length === 0) return true;
    const haystack = [
      row.id,
      row.stage,
      row.label,
      row.status,
      row.source,
      row.detail,
    ].join(" ").toLowerCase();
    return tokens.every((token) => haystack.includes(token));
  });
}

function growthMetrics(rows: GrowthSignalRow[]): GrowthMetrics {
  const value = (id: string) => rows.find((row) => row.id === id)?.value ?? 0;
  return {
    signals: rows.length,
    watch: rows.filter((row) => row.status !== "ready").length,
    signupsThisWeek: value("signupsThisWeek"),
    bookings: value("bookings"),
  };
}

function readableId(value: string): string {
  return value
    .replace(/([a-z0-9])([A-Z])/g, "$1 $2")
    .replace(/^./, (char) => char.toUpperCase());
}

function messageFromError(error: unknown, fallback: string): string {
  if (error && typeof error === "object" && "message" in error) {
    const message = (error as {message?: unknown}).message;
    if (typeof message === "string" && message.trim()) return message;
  }
  return fallback;
}
