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

export type EventPublishingView = "list" | "detail" | "external";

export interface ExternalEventPublishRequest {
  sourceActionId: string;
  targetPath: string;
  reviewNote: string;
  checklist: AdminPublishExternalEventPayload["checklist"];
}

export function useEventPublishingController({
  onError,
  onNotice,
}: {
  onError: (message: string | null) => void;
  onNotice: (message: string | null) => void;
}) {
  const queryClient = useQueryClient();
  const [selectedExternalEventId, setSelectedExternalEventId] =
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
    useState<ExternalEventSupplyFilter>("reviewOpen");
  const [view, setView] = useState<EventPublishingView>("list");
  const [eventId, setEventId] = useState("");
  const [loadedEventId, setLoadedEventId] = useState<string | null>(null);
  const [event, setEvent] = useState<AdminEventDetails | null>(null);
  const [form, setForm] = useState<EventPublishingFormState | null>(null);
  const listPayload = useMemo(
    () => buildEventListPayload(filter, debouncedQuery),
    [debouncedQuery, filter]
  );
  const externalListPayload = useMemo(
    () => buildExternalEventListPayload(externalFilter, debouncedExternalQuery),
    [debouncedExternalQuery, externalFilter]
  );
  const listQuery = useQuery({
    queryKey: adminQueryKeys.events.list(JSON.stringify(listPayload)),
    queryFn: () => listEventProfiles(listPayload),
    placeholderData: (previousData) => previousData,
  });
  const externalListQuery = useQuery({
    queryKey: adminQueryKeys.events.externalList(
      JSON.stringify(externalListPayload)
    ),
    queryFn: () => listExternalEventProfiles(externalListPayload),
    placeholderData: (previousData) => previousData,
  });
  const supplyReadinessQuery = useQuery({
    queryKey: adminQueryKeys.events.supplyReadiness(),
    queryFn: loadEventSupplyReadiness,
    placeholderData: (previousData) => previousData,
  });
  const detailEventId = loadedEventId ?? "__none__";
  const detailQuery = useQuery({
    enabled: Boolean(loadedEventId),
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

  const loadEvent = useCallback(async (nextEventId = eventId) => {
    const normalizedEventId = nextEventId.trim();
    if (!normalizedEventId) {
      onError("Enter an events/{id} document id before loading.");
      return false;
    }
    setLoadedEventId(normalizedEventId);
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
  }, [eventId, onError, queryClient]);

  const selectEvent = useCallback((nextEventId: string) => {
    setEventId(nextEventId);
    setView("detail");
    void loadEvent(nextEventId);
  }, [loadEvent]);

  const backToList = useCallback(() => {
    setView("list");
    onError(null);
  }, [onError]);

  const openExternalSupply = useCallback(() => {
    setView("external");
    onError(null);
  }, [onError]);

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
    if (filteredExternalRows.length === 0) return null;
    return filteredExternalRows.find((row) =>
      row.eventId === selectedExternalEventId) ?? filteredExternalRows[0];
  }, [filteredExternalRows, selectedExternalEventId]);
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
      setLoadedEventId(refreshed.event.eventId);
      await refreshList();
      onError(null);
      onNotice(`Saved ${result.updatedFieldCount} event field updates.`);
      return true;
    } catch (error) {
      onError(messageFromError(error, "Unable to save event profile."));
      return false;
    }
  }, [
    event,
    form,
    onError,
    onNotice,
    queryClient,
    refreshList,
    saveMutation,
  ]);

  const publishExternalEvent = useCallback(async (
    publishRequest: ExternalEventPublishRequest
  ) => {
    if (!publishRequest.reviewNote.trim()) {
      onError("Add a review note before publishing external supply.");
      return false;
    }
    try {
      const result = await publishExternalMutation.mutateAsync({
        sourceActionId: publishRequest.sourceActionId,
        targetPath: publishRequest.targetPath,
        reviewNote: publishRequest.reviewNote.trim(),
        checklist: publishRequest.checklist,
      });
      await Promise.all([
        refreshExternalList(),
        refreshSupplyReadiness(),
      ]);
      onError(null);
      onNotice(`Published ${result.targetPath} as read-only external supply.`);
      return true;
    } catch (error) {
      onError(messageFromError(error, "Unable to publish external event."));
      return false;
    }
  }, [
    onError,
    onNotice,
    publishExternalMutation,
    refreshExternalList,
    refreshSupplyReadiness,
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
    isExternalListLoading: externalListQuery.isPending ||
      externalListQuery.isFetching,
    isListLoading: listQuery.isPending || listQuery.isFetching,
    isSaving: saveMutation.isPending,
    isSupplyReadinessLoading: supplyReadinessQuery.isPending ||
      supplyReadinessQuery.isFetching,
    listGeneratedAt,
    publishingExternalActionId: publishExternalMutation.isPending ?
      publishExternalMutation.variables?.sourceActionId ?? null :
      null,
    query,
    rows,
    selectedExternalEvent,
    selectedExternalEventId: selectedExternalEvent?.eventId ?? null,
    selectedExternalImportReview,
    supplyReadiness,
    validationIssues,
    view,
    openExternalSupply,
    publishExternalEvent,
    refreshExternalList,
    refreshList,
    refreshSupplyReadiness,
    save,
    selectEvent,
    selectExternalEvent: setSelectedExternalEventId,
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
