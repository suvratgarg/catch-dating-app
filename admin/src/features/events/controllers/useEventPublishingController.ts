import {useMutation, useQuery, useQueryClient} from "@tanstack/react-query";
import {useCallback, useEffect, useMemo, useState} from "react";
import type {
  AdminEventDetails,
  AdminEventListRow,
  AdminExternalEventListRow,
  AdminListExternalEventDetailsPayload,
  AdminListEventDetailsPayload,
  AdminPublishExternalEventPayload,
} from "../../../shared/types/adminTypes";
import {
  listExternalEventProfiles,
  listEventProfiles,
  loadEventSupplyReadiness,
  loadEventProfile,
  publishExternalEventProfile,
  saveEventProfile,
} from "../api/eventPublishingRepository";
import {
  buildExternalEventImportReview,
  buildEventSavePayload,
  diffEventProfile,
  externalEventNeedsReview,
  eventIsFull,
  eventNeedsSearchBackfill,
  formFromEventProfile,
  hasBlockingEventIssues,
  validateEventPublishingForm,
  type EventPublishingFormState,
} from "./eventPublishingHelpers";
import {
  isLaunchMarketId,
  isLaunchMarketSlug,
  launchMarketIds,
  launchMarketSlugs,
} from "../../../shared/config/launchMarkets";
import {adminQueryKeys} from "../../../shared/query/queryKeys";
import {useAdminPendingOperationGuard} from "../../../shared/pendingOperation";

export type EventPublishingFilter =
  | "launchCities"
  | "all"
  | "upcoming"
  | "active"
  | "cancelled"
  | "full"
  | "searchIssues";

export type ExternalEventSupplyFilter =
  | "launchCities"
  | "reviewOpen"
  | "upcoming"
  | "public"
  | "all"
  | "active"
  | "cancelled";

export type EventPublishingWorkspace = "directory" | "readiness" | "external";
export type EventPublishingView = "list" | "detail" | "readiness" | "external";

export interface ExternalEventPublishRequest {
  sourceActionId: string;
  targetPath: string;
  reviewNote: string;
  checklist: AdminPublishExternalEventPayload["checklist"];
}

export function useEventPublishingController({
  activeWorkspace = "directory",
  onBackToList,
  onError,
  onNotice,
  onSelectEventId,
  onSelectExternalEventId,
  onSelectReadinessActionId,
  onWorkspaceChange,
  selectedEventId: controlledSelectedEventId,
  selectedExternalEventId: controlledSelectedExternalEventId,
  selectedReadinessActionId = null,
}: {
  activeWorkspace?: EventPublishingWorkspace;
  onBackToList?: () => void;
  onError: (message: string | null) => void;
  onNotice: (message: string | null) => void;
  onSelectEventId?: (eventId: string) => void;
  onSelectExternalEventId?: (eventId: string | null) => void;
  onSelectReadinessActionId?: (sourceActionId: string | null) => void;
  onWorkspaceChange?: (workspace: EventPublishingWorkspace) => void;
  selectedEventId?: string | null;
  selectedExternalEventId?: string | null;
  selectedReadinessActionId?: string | null;
}) {
  const queryClient = useQueryClient();
  const {beginOperation, endOperation} = useAdminPendingOperationGuard();
  const [localSelectedExternalEventId, setLocalSelectedExternalEventId] =
    useState<string | null>(null);
  const [query, setQuery] = useState("");
  const [externalQuery, setExternalQuery] = useState("");
  const debouncedQuery = useDebouncedValue(query, query.trim() ? 250 : 0);
  const debouncedExternalQuery = useDebouncedValue(
    externalQuery,
    externalQuery.trim() ? 250 : 0
  );
  const [filter, setFilter] =
    useState<EventPublishingFilter>("launchCities");
  const [externalFilter, setExternalFilter] =
    useState<ExternalEventSupplyFilter>(
      activeWorkspace === "external" ? "public" : "reviewOpen"
    );
  const [eventId, setEventId] = useState("");
  const [localSelectedEventId, setLocalSelectedEventId] =
    useState<string | null>(null);
  const [event, setEvent] = useState<AdminEventDetails | null>(null);
  const [form, setForm] = useState<EventPublishingFormState | null>(null);
  const selectedEventId = controlledSelectedEventId === undefined ?
    localSelectedEventId :
    controlledSelectedEventId;
  const selectedExternalEventId = controlledSelectedExternalEventId === undefined ?
    localSelectedExternalEventId :
    controlledSelectedExternalEventId;
  const setSelectedEventId = useCallback((nextEventId: string | null) => {
    if (controlledSelectedEventId === undefined) {
      setLocalSelectedEventId(nextEventId);
    }
    if (nextEventId) onSelectEventId?.(nextEventId);
  }, [controlledSelectedEventId, onSelectEventId]);
  const setSelectedExternalEventId = useCallback((nextEventId: string | null) => {
    if (controlledSelectedExternalEventId === undefined) {
      setLocalSelectedExternalEventId(nextEventId);
    }
    onSelectExternalEventId?.(nextEventId);
  }, [controlledSelectedExternalEventId, onSelectExternalEventId]);
  const view: EventPublishingView = selectedEventId ?
    "detail" :
    activeWorkspace === "directory" ? "list" : activeWorkspace;
  const listPayload = useMemo(
    () => buildEventListPayload(filter, debouncedQuery),
    [debouncedQuery, filter]
  );
  const externalListPayload = useMemo(
    () => ({
      ...buildExternalEventListPayload(externalFilter, debouncedExternalQuery),
      publicationStatus: "public" as const,
    }),
    [debouncedExternalQuery, externalFilter]
  );
  const listQuery = useQuery({
    enabled: activeWorkspace === "directory" && !selectedEventId,
    queryKey: adminQueryKeys.events.list(JSON.stringify(listPayload)),
    queryFn: () => listEventProfiles(listPayload),
    placeholderData: (previousData) => previousData,
  });
  const externalListQuery = useQuery({
    enabled: activeWorkspace === "external" && !selectedExternalEventId,
    queryKey: adminQueryKeys.events.externalList(
      JSON.stringify(externalListPayload)
    ),
    queryFn: () => listExternalEventProfiles(externalListPayload),
    placeholderData: (previousData) => previousData,
  });
  const externalDetailQuery = useQuery({
    enabled: activeWorkspace === "external" && Boolean(selectedExternalEventId),
    queryKey: adminQueryKeys.events.externalList(JSON.stringify({
      query: selectedExternalEventId,
      publicationStatus: "public",
      timeWindow: "all",
      limit: 10,
    })),
    queryFn: () => listExternalEventProfiles({
      query: selectedExternalEventId,
      publicationStatus: "public",
      timeWindow: "all",
      limit: 10,
    }),
  });
  const supplyReadinessQuery = useQuery({
    enabled: activeWorkspace === "readiness",
    queryKey: adminQueryKeys.events.supplyReadiness(),
    queryFn: loadEventSupplyReadiness,
    placeholderData: (previousData) => previousData,
  });
  const detailEventId = selectedEventId ?? "__none__";
  const detailQuery = useQuery({
    enabled: Boolean(selectedEventId),
    queryKey: adminQueryKeys.events.detail(detailEventId),
    queryFn: () => loadEventProfile({eventId: detailEventId}),
  });
  const saveMutation = useMutation({
    mutationFn: saveEventProfile,
  });
  const publishExternalMutation = useMutation({
    mutationFn: publishExternalEventProfile,
  });
  const rows = listQuery.data?.rows ?? [];
  const externalRows = externalListQuery.data?.rows ?? [];
  const listGeneratedAt = listQuery.data?.generatedAt ?? null;
  const externalListGeneratedAt = externalListQuery.data?.generatedAt ?? null;
  const supplyReadiness = supplyReadinessQuery.data ?? null;

  const refreshList = useCallback(async () => {
    const result = await listQuery.refetch();
    if (result.error) {
      onError(messageFromError(result.error, "Unable to load event profiles."));
      return false;
    }
    return true;
  }, [listQuery, onError]);

  const refreshExternalList = useCallback(async () => {
    const result = await externalListQuery.refetch();
    if (result.error) {
      onError(messageFromError(
        result.error,
        "Unable to load external event supply."
      ));
      return false;
    }
    return true;
  }, [externalListQuery, onError]);

  const refreshSupplyReadiness = useCallback(async () => {
    const result = await supplyReadinessQuery.refetch();
    if (result.error) {
      onError(messageFromError(
        result.error,
        "Unable to load event import readiness."
      ));
      return false;
    }
    return true;
  }, [onError, supplyReadinessQuery]);

  useEffect(() => {
    if (!listQuery.error) return;
    onError(messageFromError(listQuery.error, "Unable to load event profiles."));
  }, [listQuery.error, onError]);

  useEffect(() => {
    if (!externalListQuery.error) return;
    onError(messageFromError(
      externalListQuery.error,
      "Unable to load external event supply."
    ));
  }, [externalListQuery.error, onError]);

  useEffect(() => {
    if (!externalDetailQuery.error) return;
    onError(messageFromError(
      externalDetailQuery.error,
      "Unable to load external event detail."
    ));
  }, [externalDetailQuery.error, onError]);

  useEffect(() => {
    if (!supplyReadinessQuery.error) return;
    onError(messageFromError(
      supplyReadinessQuery.error,
      "Unable to load event import readiness."
    ));
  }, [onError, supplyReadinessQuery.error]);

  useEffect(() => {
    if (!detailQuery.error) return;
    onError(messageFromError(detailQuery.error, "Unable to load event profile."));
  }, [detailQuery.error, onError]);

  useEffect(() => {
    if (!detailQuery.data) return;
    setEvent(detailQuery.data.event);
    setForm(formFromEventProfile(detailQuery.data.event));
    setEventId(detailQuery.data.event.eventId);
    onError(null);
  }, [detailQuery.data, onError]);

  useEffect(() => {
    if (!selectedEventId) {
      setEvent(null);
      setForm(null);
      return;
    }
    setEventId(selectedEventId);
    setEvent((current) => current?.eventId === selectedEventId ? current : null);
    setForm((current) => event?.eventId === selectedEventId ? current : null);
  }, [event?.eventId, selectedEventId]);

  const loadEvent = useCallback(async (nextEventId = eventId) => {
    const normalizedEventId = nextEventId.trim();
    if (!normalizedEventId) {
      onError("Enter an events/{id} document id before loading.");
      return false;
    }
    setSelectedEventId(normalizedEventId);
    try {
      const response = await queryClient.fetchQuery({
        queryKey: adminQueryKeys.events.detail(normalizedEventId),
        queryFn: () => loadEventProfile({eventId: normalizedEventId}),
        staleTime: 0,
      });
      setEvent(response.event);
      setForm(formFromEventProfile(response.event));
      setEventId(response.event.eventId);
      onError(null);
      return true;
    } catch (error) {
      onError(messageFromError(error, "Unable to load event profile."));
      return false;
    }
  }, [eventId, onError, queryClient, setSelectedEventId]);

  const selectEvent = useCallback((nextEventId: string) => {
    setEventId(nextEventId);
    setSelectedEventId(nextEventId);
    if (!onSelectEventId) void loadEvent(nextEventId);
  }, [loadEvent, onSelectEventId, setSelectedEventId]);

  const backToList = useCallback(() => {
    if (controlledSelectedEventId === undefined) {
      setLocalSelectedEventId(null);
    }
    onError(null);
    onBackToList?.();
  }, [controlledSelectedEventId, onBackToList, onError]);

  const openExternalSupply = useCallback(() => {
    onWorkspaceChange?.("external");
    onError(null);
  }, [onError, onWorkspaceChange]);

  const openReadiness = useCallback(() => {
    onWorkspaceChange?.("readiness");
    onError(null);
  }, [onError, onWorkspaceChange]);

  const diffRows = useMemo(
    () => diffEventProfile(event, form),
    [event, form]
  );
  const validationIssues = useMemo(
    () => validateEventPublishingForm(
      form,
      {requireReviewNote: diffRows.length > 0}
    ),
    [diffRows.length, form]
  );
  const filteredRows = useMemo(
    () => filterEventRows(rows, filter, listGeneratedAt),
    [filter, listGeneratedAt, rows]
  );
  const filteredExternalRows = useMemo(
    () => filterExternalEventRows(
      externalRows,
      externalFilter,
      externalListGeneratedAt
    ),
    [externalFilter, externalListGeneratedAt, externalRows]
  );
  const selectedExternalEvent = useMemo(() => {
    const rowsToSearch = [
      ...(externalDetailQuery.data?.rows ?? []),
      ...filteredExternalRows,
    ];
    return rowsToSearch.find((row) =>
      row.eventId === selectedExternalEventId) ?? null;
  }, [externalDetailQuery.data?.rows, filteredExternalRows, selectedExternalEventId]);
  const selectedExternalImportReview = useMemo(
    () => buildExternalEventImportReview(
      selectedExternalEvent,
      supplyReadiness?.importPlan ?? null,
      supplyReadiness?.executionPlan ?? null
    ),
    [selectedExternalEvent, supplyReadiness]
  );

  const save = useCallback(async () => {
    if (!event || !form) {
      onError("Load an event before saving.");
      return false;
    }
    const payload = buildEventSavePayload(event, form);
    if (Object.keys(payload.fields).length === 0) {
      onNotice("No event changes to save.");
      return true;
    }
    const issues = validateEventPublishingForm(form, {
      requireReviewNote: true,
    });
    if (hasBlockingEventIssues(issues)) {
      onError(issues.find((issue) => issue.severity === "blocker")?.detail ??
        "Resolve event validation issues before saving.");
      return false;
    }
    const operation = beginOperation();
    if (!operation) return false;
    try {
      const result = await saveMutation.mutateAsync(payload);
      const refreshed = await queryClient.fetchQuery({
        queryKey: adminQueryKeys.events.detail(result.eventId),
        queryFn: () => loadEventProfile({eventId: result.eventId}),
        staleTime: 0,
      });
      setEvent(refreshed.event);
      setForm(formFromEventProfile(refreshed.event));
      setEventId(refreshed.event.eventId);
      setSelectedEventId(refreshed.event.eventId);
      await queryClient.invalidateQueries({
        queryKey: [...adminQueryKeys.all, "events", "list"],
      });
      onError(null);
      onNotice(`Saved ${result.updatedFieldCount} event field updates.`);
      return true;
    } catch (error) {
      onError(messageFromError(error, "Unable to save event profile."));
      return false;
    } finally {
      endOperation(operation);
    }
  }, [
    beginOperation,
    endOperation,
    event,
    form,
    onError,
    onNotice,
    queryClient,
    saveMutation,
    setSelectedEventId,
  ]);

  const publishExternalEvent = useCallback(async (
    publishRequest: ExternalEventPublishRequest
  ) => {
    if (!publishRequest.reviewNote.trim()) {
      onError("Add a review note before publishing external supply.");
      return false;
    }
    const operation = beginOperation();
    if (!operation) return false;
    try {
      const result = await publishExternalMutation.mutateAsync({
        sourceActionId: publishRequest.sourceActionId,
        targetPath: publishRequest.targetPath,
        reviewNote: publishRequest.reviewNote.trim(),
        checklist: publishRequest.checklist,
      });
      await Promise.all([
        queryClient.invalidateQueries({
          queryKey: [...adminQueryKeys.all, "events", "external-list"],
        }),
        queryClient.invalidateQueries({
          queryKey: adminQueryKeys.events.supplyReadiness(),
        }),
      ]);
      onError(null);
      onNotice(`Published ${result.targetPath} as read-only external supply.`);
      return true;
    } catch (error) {
      onError(messageFromError(error, "Unable to publish external event."));
      return false;
    } finally {
      endOperation(operation);
    }
  }, [
    beginOperation,
    endOperation,
    onError,
    onNotice,
    publishExternalMutation,
    queryClient,
  ]);

  return {
    backToList,
    diffRows,
    event,
    eventId,
    externalFilter,
    externalQuery,
    externalListGeneratedAt,
    externalRows,
    filter,
    filteredExternalRows,
    filteredRows,
    form,
    isDetailLoading: detailQuery.isPending || detailQuery.isFetching,
    isExternalListLoading: activeWorkspace === "external" && (
      selectedExternalEventId ?
        externalDetailQuery.isPending || externalDetailQuery.isFetching :
        externalListQuery.isPending || externalListQuery.isFetching
    ),
    isListLoading: activeWorkspace === "directory" &&
      !selectedEventId && (listQuery.isPending || listQuery.isFetching),
    isSaving: saveMutation.isPending,
    isSupplyReadinessLoading: activeWorkspace === "readiness" &&
      (supplyReadinessQuery.isPending || supplyReadinessQuery.isFetching),
    listGeneratedAt,
    publishingExternalActionId: publishExternalMutation.isPending ?
      publishExternalMutation.variables?.sourceActionId ?? null :
      null,
    query,
    rows,
    selectedExternalEvent,
    selectedExternalEventId,
    selectedExternalImportReview,
    selectedReadinessActionId,
    supplyReadiness,
    validationIssues,
    view,
    openExternalSupply,
    openReadiness,
    publishExternalEvent,
    refreshExternalList,
    refreshList,
    refreshSupplyReadiness,
    save,
    selectEvent,
    selectExternalEvent: setSelectedExternalEventId,
    selectReadinessAction: onSelectReadinessActionId ?? (() => undefined),
    setEventId,
    setExternalFilter,
    setExternalQuery,
    setFilter,
    setForm,
    setQuery,
  };
}

export type EventPublishingController =
  ReturnType<typeof useEventPublishingController>;

function useDebouncedValue(value: string, delayMs: number) {
  const [debouncedValue, setDebouncedValue] = useState(value);
  useEffect(() => {
    const timer = window.setTimeout(() => setDebouncedValue(value), delayMs);
    return () => window.clearTimeout(timer);
  }, [delayMs, value]);
  return debouncedValue;
}

export function filterEventRows(
  rows: AdminEventListRow[],
  filter: EventPublishingFilter,
  generatedAt?: string | null
): AdminEventListRow[] {
  const now = snapshotTimeMillis(generatedAt);
  return rows.filter((row) => {
    if (filter === "launchCities" && !isLaunchMarketId(row.citySlug)) {
      return false;
    }
    if (filter === "launchCities" && row.status !== "active") return false;
    if (filter === "launchCities" && !eventIsUpcoming(row, now)) return false;
    if (filter === "upcoming" && !eventIsUpcoming(row, now)) return false;
    if (filter === "upcoming" && row.status !== "active") return false;
    if (filter === "active" && row.status !== "active") return false;
    if (filter === "cancelled" && row.status !== "cancelled") return false;
    if (
      filter === "full" &&
      (
        row.status !== "active" ||
        !eventIsFull(row) ||
        !eventIsUpcoming(row, now)
      )
    ) {
      return false;
    }
    if (filter === "searchIssues" && !eventNeedsSearchBackfill(row)) {
      return false;
    }
    return true;
  });
}

export function buildEventListPayload(
  filter: EventPublishingFilter,
  query: string
): AdminListEventDetailsPayload {
  return {
    query: query.trim() || null,
    citySlugs: filter === "launchCities" ? Array.from(launchMarketIds) : null,
    status: eventStatusForFilter(filter),
    timeWindow: eventTimeWindowForFilter(filter),
    limit: 100,
  };
}

export function filterExternalEventRows(
  rows: AdminExternalEventListRow[],
  filter: ExternalEventSupplyFilter,
  generatedAt?: string | null
): AdminExternalEventListRow[] {
  const now = snapshotTimeMillis(generatedAt);
  return rows.filter((row) => {
    if (filter === "reviewOpen") {
      return isLaunchMarketSlug(row.citySlug) &&
        externalEventNeedsReview(row);
    }
    if (filter === "launchCities" && !isLaunchMarketSlug(row.citySlug)) {
      return false;
    }
    if (filter === "launchCities" && row.status !== "active") return false;
    if (filter === "launchCities" && row.publicationStatus !== "public") {
      return false;
    }
    if (filter === "launchCities" && !externalEventIsUpcoming(row, now)) {
      return false;
    }
    if (filter === "upcoming" && !externalEventIsUpcoming(row, now)) {
      return false;
    }
    if (filter === "upcoming" && row.status !== "active") return false;
    if (filter === "upcoming" && row.publicationStatus !== "public") {
      return false;
    }
    if (filter === "public" && row.publicationStatus !== "public") {
      return false;
    }
    if (filter === "active" && row.status !== "active") return false;
    if (filter === "cancelled" && row.status !== "cancelled") return false;
    return true;
  });
}

export function buildExternalEventListPayload(
  filter: ExternalEventSupplyFilter,
  query: string
): AdminListExternalEventDetailsPayload {
  return {
    query: query.trim() || null,
    citySlugs:
      filter === "launchCities" || filter === "reviewOpen" ?
        Array.from(launchMarketSlugs) :
        null,
    publicationStatus: externalPublicationStatusForFilter(filter),
    status: eventStatusForFilter(filter),
    timeWindow: eventTimeWindowForFilter(filter),
    limit: 100,
  };
}

function eventStatusForFilter(
  filter: EventPublishingFilter | ExternalEventSupplyFilter
): AdminListEventDetailsPayload["status"] {
  if (
    filter === "launchCities" ||
    filter === "upcoming" ||
    filter === "full" ||
    filter === "active"
  ) {
    return "active";
  }
  if (filter === "cancelled") return "cancelled";
  return null;
}

function externalPublicationStatusForFilter(
  filter: ExternalEventSupplyFilter
): AdminListExternalEventDetailsPayload["publicationStatus"] {
  if (
    filter === "launchCities" ||
    filter === "upcoming" ||
    filter === "public"
  ) {
    return "public";
  }
  return null;
}

function eventTimeWindowForFilter(
  filter: EventPublishingFilter | ExternalEventSupplyFilter
): AdminListEventDetailsPayload["timeWindow"] {
  if (
    filter === "launchCities" ||
    filter === "upcoming" ||
    filter === "full"
  ) {
    return "upcoming";
  }
  return "all";
}

function eventIsUpcoming(
  row: Pick<AdminEventListRow, "startTime">,
  nowMillis: number
): boolean {
  if (!row.startTime) return false;
  const startMillis = Date.parse(row.startTime);
  return Number.isFinite(startMillis) && startMillis >= nowMillis;
}

function externalEventIsUpcoming(
  row: Pick<AdminExternalEventListRow, "startTime">,
  nowMillis: number
): boolean {
  if (!row.startTime) return false;
  const startMillis = Date.parse(row.startTime);
  return Number.isFinite(startMillis) && startMillis >= nowMillis;
}

function snapshotTimeMillis(generatedAt?: string | null): number {
  if (generatedAt) {
    const parsed = Date.parse(generatedAt);
    if (Number.isFinite(parsed)) return parsed;
  }
  return Number.NaN;
}

function messageFromError(error: unknown, fallback: string): string {
  if (error && typeof error === "object" && "message" in error) {
    const message = (error as {message?: unknown}).message;
    if (typeof message === "string" && message.trim()) return message;
  }
  return fallback;
}
