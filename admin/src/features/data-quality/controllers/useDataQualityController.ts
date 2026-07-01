import {useCallback, useEffect, useMemo, useState} from "react";
import {useQuery} from "@tanstack/react-query";
import {
  loadDataQualitySnapshot,
  type DataQualitySnapshot,
} from "../api/dataQualityRepository";
import {adminQueryKeys} from "../../../shared/query/queryKeys";

export type DataQualityState =
  | "ok"
  | "warning"
  | "partial"
  | "missing"
  | "blocked";
export type DataQualityStateFilter = "all" | DataQualityState;

export interface DataQualityRow {
  id: string;
  source: string;
  label: string;
  state: DataQualityState;
  detail: string;
  owner: string;
  runbook: string;
  nextAction: string;
  updatedAt: string | null;
}

export interface DataQualityMetrics {
  total: number;
  blocking: number;
  watch: number;
  ok: number;
  sources: number;
}

export function useDataQualityController({
  onError,
}: {
  onError: (message: string | null) => void;
}) {
  const [query, setQuery] = useState("");
  const [stateFilter, setStateFilter] =
    useState<DataQualityStateFilter>("all");
  const [selectedId, setSelectedId] = useState<string | null>(null);

  const snapshotQuery = useQuery({
    queryKey: adminQueryKeys.dataQuality.snapshot(),
    queryFn: loadDataQualitySnapshot,
  });

  const rows = useMemo(
    () => snapshotQuery.data ? buildDataQualityRows(snapshotQuery.data) : [],
    [snapshotQuery.data]
  );
  const generatedAt = snapshotQuery.data?.generatedAt ?? null;
  const isLoading = snapshotQuery.isPending || snapshotQuery.isFetching;

  useEffect(() => {
    if (snapshotQuery.isError) {
      onError(messageFromError(
        snapshotQuery.error,
        "Unable to load data-quality signals."
      ));
      return;
    }
    if (snapshotQuery.isSuccess) {
      onError(null);
    }
  }, [
    onError,
    snapshotQuery.error,
    snapshotQuery.isError,
    snapshotQuery.isSuccess,
  ]);

  useEffect(() => {
    setSelectedId((current) => {
      if (current && rows.some((row) => row.id === current)) {
        return current;
      }
      return rows.find((row) => row.state !== "ok")?.id ??
        rows[0]?.id ??
        null;
    });
  }, [rows]);

  const refresh = useCallback(async () => {
    await snapshotQuery.refetch();
  }, [snapshotQuery]);

  const filteredRows = useMemo(
    () => filterRows(rows, stateFilter, query),
    [query, rows, stateFilter]
  );
  const metrics = useMemo(() => dataQualityMetrics(rows), [rows]);
  const selected = useMemo(
    () => rows.find((row) => row.id === selectedId) ?? null,
    [rows, selectedId]
  );

  const select = useCallback((row: DataQualityRow) => {
    setSelectedId(row.id);
    onError(null);
  }, [onError]);

  return {
    filteredRows,
    generatedAt,
    isLoading,
    metrics,
    query,
    rows,
    selected,
    stateFilter,
    refresh,
    select,
    setQuery,
    setStateFilter,
  };
}

function buildDataQualityRows(snapshot: Awaited<
  ReturnType<typeof loadDataQualitySnapshot>
>): DataQualityRow[] {
  const overviewRows = snapshot.overview.dataQuality.map((row) => ({
    id: `overview-${row.id}`,
    source: "Overview",
    label: row.label,
    state: row.state,
    detail: row.detail,
    owner: row.owner,
    runbook: row.runbook,
    nextAction: row.nextAction,
    updatedAt: snapshot.overview.generatedAt,
  }));
  const analyticsRows = snapshot.hostAnalytics.dataQuality.map((row) => ({
    id: `host-analytics-${row.id}`,
    source: "Host analytics",
    label: row.id,
    state: row.state,
    detail: row.detail,
    owner: row.owner,
    runbook: row.runbook,
    nextAction: row.nextAction,
    updatedAt: snapshot.hostAnalytics.generatedAt,
  }));
  const bridgeGeneratedAt = snapshot.marketingBridge.generatedAt ?? null;
  const bridgeAgeDays = ageInDays(bridgeGeneratedAt);
  const bridgeRow: DataQualityRow = {
    id: "generated-marketing-bridge",
    source: "Generated bridge",
    label: "Marketing ops bridge",
    state: bridgeAgeDays === null ? "missing" :
      bridgeAgeDays > 7 ? "warning" : "ok",
    detail: bridgeGeneratedAt ?
      `Generated ${formatAge(bridgeGeneratedAt)} for ` +
        `${snapshot.marketingBridge.city.label} ${snapshot.marketingBridge.weekStart}.` :
      "Generated timestamp is missing from the marketing bridge.",
    owner: "Marketing ops",
    runbook: "admin/src/generated/marketingOpsBridge.json",
    nextAction: bridgeAgeDays !== null && bridgeAgeDays <= 7 ?
      "No action; generated bridge is fresh enough for the launch workspace." :
      "Regenerate the marketing ops bridge before publishing new campaign work.",
    updatedAt: bridgeGeneratedAt,
  };
  const eventIntakeRow =
    buildEventIntakeDashboardRow(snapshot.eventIntakeBridge);
  const marketingJobHealthRow = buildRunPlanJobHealthRow({
    id: "marketing-run-plan-job-health",
    source: "Marketing job health",
    label: "Marketing source crawl run plan",
    owner: "Marketing ops",
    runbook: "admin > Marketing > Crawl setup",
    runPlan: snapshot.marketingBridge.runPlan,
  });
  const eventIntakeJobHealthRow = buildRunPlanJobHealthRow({
    id: "event-intake-run-plan-job-health",
    source: "Event Intake job health",
    label: "Event Intake source crawl run plan",
    owner: "Events intake",
    runbook: "admin > Intake > Crawl setup",
    runPlan: snapshot.eventIntakeBridge.runPlan,
  });
  const eventReadinessRows =
    buildEventSupplyReadinessRows(snapshot.eventSupplyReadiness);
  const eventImportPolicyRow =
    buildEventImportPolicyHealthRow(snapshot.eventSupplyReadiness);
  return [
    ...overviewRows,
    ...analyticsRows,
    bridgeRow,
    marketingJobHealthRow,
    eventIntakeRow,
    eventIntakeJobHealthRow,
    ...eventReadinessRows,
    eventImportPolicyRow,
  ]
    .sort((a, b) => stateRank(b.state) - stateRank(a.state) ||
      a.source.localeCompare(b.source) ||
      a.label.localeCompare(b.label));
}

function buildEventIntakeDashboardRow(
  eventIntakeBridge: DataQualitySnapshot["eventIntakeBridge"]
): DataQualityRow {
  const generatedAt = eventIntakeBridge.generatedAt ?? null;
  const ageDays = ageInDays(generatedAt);
  const isEmpty = eventIntakeBridge.bridgeSource === "empty";
  const state: DataQualityState = isEmpty || ageDays === null ? "missing" :
    ageDays > 7 ? "warning" : "ok";
  const eventCandidates = arrayLength(eventIntakeBridge.eventCandidates);
  const sourceResults = arrayLength(eventIntakeBridge.sourceResults);
  return {
    id: "event-intake-dashboard-freshness",
    source: "Event Intake dashboard",
    label: "Event Intake bridge",
    state,
    detail: generatedAt ?
      `${eventIntakeSourceLabel(eventIntakeBridge.bridgeSource)} bridge ` +
        `generated ${formatAge(generatedAt)} with ${eventCandidates} ` +
        `candidates from ${sourceResults} source results.` :
      "No Event Intake dashboard bridge is published.",
    owner: "Events intake",
    runbook: "tool/marketing/event_guide/publish_event_intake_dashboard.mjs",
    nextAction: eventIntakeNextAction(state),
    updatedAt: generatedAt,
  };
}

function buildRunPlanJobHealthRow({
  id,
  label,
  owner,
  runbook,
  runPlan,
  source,
}: {
  id: string;
  label: string;
  owner: string;
  runbook: string;
  runPlan: DataQualitySnapshot["marketingBridge"]["runPlan"];
  source: string;
}): DataQualityRow {
  const automation = runPlan.automationPolicy;
  const notConfigured = automation.searchProvider === "not_configured";
  const networkDisabled = !automation.networkFetchesEnabled;
  const state: DataQualityState = notConfigured || networkDisabled ?
    "partial" :
    runPlan.status === "paused" ? "warning" : "ok";
  const blockers = [
    notConfigured ? "search provider not configured" : null,
    networkDisabled ? "network fetches disabled" : null,
    automation.instagramScrapingEnabled ? null : "Instagram scraping disabled",
  ].filter((item): item is string => item !== null);
  return {
    id,
    source,
    label,
    state,
    detail:
      `Run plan ${runPlan.status}; ${runPlan.schedule.cadence} cadence; ` +
      `${runPlan.budgets.maxQueries} max queries; ` +
      `provider ${automation.searchProvider}; ` +
      `${blockers.length > 0 ? blockers.join(", ") : "automation enabled"}.`,
    owner,
    runbook,
    nextAction: state === "ok" ?
      "No action; source run plan is configured for automated fetches." :
      "Treat stale bridge artifacts as disabled/manual intake until search provider and network fetch policy are configured.",
    updatedAt: runPlan.generatedAt,
  };
}

function buildEventSupplyReadinessRows(
  eventSupplyReadiness: DataQualitySnapshot["eventSupplyReadiness"]
): DataQualityRow[] {
  const generatedAt = eventSupplyReadiness.generatedAt ?? null;
  const ageDays = ageInDays(generatedAt);
  const isEmpty = eventSupplyReadiness.source === "empty";
  const isSample = eventSupplyReadiness.source === "sample";
  const sourceLabel = sourceModeLabel(eventSupplyReadiness.source);
  const freshnessState: DataQualityState = isEmpty || ageDays === null ?
    "missing" :
    isSample ? "partial" :
      ageDays > 7 ? "warning" : "ok";
  const freshnessRow: DataQualityRow = {
    id: "event-supply-readiness-freshness",
    source: "Event supply readiness",
    label: "External event import readiness",
    state: freshnessState,
    detail: generatedAt ?
      `${sourceLabel} snapshot generated ${formatAge(generatedAt)}.` :
      "No event supply readiness snapshot is published.",
    owner: "Events intake",
    runbook: "tool/organizer_intake/publish_event_supply_readiness.mjs",
    nextAction: eventSupplyReadinessNextAction(freshnessState, isSample),
    updatedAt: generatedAt,
  };

  const blocked = eventSupplyReadiness.importPlan.summary.blocked;
  const writeReady = eventSupplyReadiness.importPlan.summary.writeReady;
  const candidates = eventSupplyReadiness.importPlan.summary.candidates;
  const payloadInvalid =
    eventSupplyReadiness.executionPlan.summary.payloadInvalid;
  const projectionInvalid =
    eventSupplyReadiness.executionPlan.summary.projectionInvalidCount ??
    eventSupplyReadiness.executionPlan.summary.projectionInvalid ??
    0;
  const issueCount = blocked + payloadInvalid + projectionInvalid;
  const preflightState: DataQualityState = isEmpty ? "missing" :
    issueCount > 0 ? "partial" : "ok";
  const preflightRow: DataQualityRow = {
    id: "event-supply-readiness-preflight",
    source: "Event supply readiness",
    label: "External event import blockers",
    state: preflightState,
    detail:
      `${candidates} candidates, ${writeReady} write-ready, ` +
      `${blocked} blocked, ${payloadInvalid} payload-invalid, ` +
      `${projectionInvalid} projection-invalid.`,
    owner: "Events intake",
    runbook: "admin > Events > External import readiness",
    nextAction: issueCount > 0 ?
      "Resolve review, location, schema, or projection blockers before publishing readiness again." :
      "No action; generated import and preflight plans have no blockers under the current disabled-write policy.",
    updatedAt: generatedAt,
  };

  return [freshnessRow, preflightRow];
}

function buildEventImportPolicyHealthRow(
  eventSupplyReadiness: DataQualitySnapshot["eventSupplyReadiness"]
): DataQualityRow {
  const generatedAt = eventSupplyReadiness.generatedAt ?? null;
  const policy = eventSupplyReadiness.executionPlan.policy;
  const writeCommand = eventSupplyReadiness.executionPlan.commands.write ??
    "not available";
  const state: DataQualityState = eventSupplyReadiness.source === "empty" ?
    "missing" :
    policy.writeEnabled ? "ok" : "partial";
  return {
    id: "event-import-execution-policy-health",
    source: "Event supply job health",
    label: "External event import execution policy",
    state,
    detail:
      `Execution policy is ${policy.status}; authority ` +
      `${policy.authorityModel}; write command: ${writeCommand}.`,
    owner: "Events intake",
    runbook: "tool/organizer_intake/preflight_external_event_imports.mjs",
    nextAction: policy.writeEnabled ?
      "No action; import execution policy is write-enabled." :
      "Do not treat missing external-event writes as a failed scheduler; writes are disabled until import authority, defaults, and rollback policy are approved.",
    updatedAt: generatedAt,
  };
}

function sourceModeLabel(
  source: DataQualitySnapshot["eventSupplyReadiness"]["source"]
): string {
  if (source === "event_supply_readiness") return "Live";
  if (source === "sample") return "Sample";
  return "Empty";
}

function eventSupplyReadinessNextAction(
  state: DataQualityState,
  isSample: boolean
): string {
  if (state === "ok") {
    return "No action; readiness was published within the last 7 days.";
  }
  if (isSample) {
    return "Use live admin data mode to verify the published Firestore readiness document.";
  }
  return "Run the publish tool dry-run, review the diff, then apply the dashboard document if correct.";
}

function eventIntakeSourceLabel(
  source: DataQualitySnapshot["eventIntakeBridge"]["bridgeSource"]
): string {
  if (source === "event_intake") return "Live";
  if (source === "native_generated") return "Generated";
  if (source === "sample") return "Sample";
  return "Empty";
}

function eventIntakeNextAction(state: DataQualityState): string {
  if (state === "ok") {
    return "No action; Event Intake dashboard was generated within the last 7 days.";
  }
  return "Regenerate the Event Intake bridge, dry-run the publish tool, then apply eventIntakeDashboards/current if correct.";
}

function arrayLength(value: unknown[] | undefined): number {
  return Array.isArray(value) ? value.length : 0;
}

function dataQualityMetrics(rows: DataQualityRow[]): DataQualityMetrics {
  return {
    total: rows.length,
    blocking: rows.filter((row) => row.state === "blocked" ||
      row.state === "missing").length,
    watch: rows.filter((row) => row.state === "warning" ||
      row.state === "partial").length,
    ok: rows.filter((row) => row.state === "ok").length,
    sources: new Set(rows.map((row) => row.source)).size,
  };
}

function filterRows(
  rows: DataQualityRow[],
  stateFilter: DataQualityStateFilter,
  query: string
): DataQualityRow[] {
  const tokens = query.trim().toLowerCase().split(/\s+/u).filter(Boolean);
  return rows.filter((row) => {
    if (stateFilter !== "all" && row.state !== stateFilter) return false;
    if (tokens.length === 0) return true;
    const haystack = [
      row.id,
      row.source,
      row.label,
      row.state,
      row.detail,
      row.owner,
      row.runbook,
      row.nextAction,
    ].join(" ").toLowerCase();
    return tokens.every((token) => haystack.includes(token));
  });
}

export function stateRank(state: DataQualityState): number {
  if (state === "blocked" || state === "missing") return 3;
  if (state === "warning" || state === "partial") return 2;
  return 1;
}

function ageInDays(value: string | null): number | null {
  if (!value) return null;
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return null;
  return Math.floor((Date.now() - date.getTime()) / 86400000);
}

function formatAge(value: string): string {
  const days = ageInDays(value);
  if (days === null) return value;
  if (days === 0) return "today";
  if (days === 1) return "1 day ago";
  return `${days} days ago`;
}

function messageFromError(error: unknown, fallback: string): string {
  if (error && typeof error === "object" && "message" in error) {
    const message = (error as {message?: unknown}).message;
    if (typeof message === "string" && message.trim()) return message;
  }
  return fallback;
}
