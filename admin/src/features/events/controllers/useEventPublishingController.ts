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
  type EventSupplyReadiness,
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
  const [rows, setRows] = useState<AdminEventListRow[]>([]);
  const [externalRows, setExternalRows] =
    useState<AdminExternalEventListRow[]>([]);
  const [selectedExternalEventId, setSelectedExternalEventId] =
    useState<string | null>(null);
  const [listGeneratedAt, setListGeneratedAt] = useState<string | null>(null);
  const [externalListGeneratedAt, setExternalListGeneratedAt] =
    useState<string | null>(null);
  const [supplyReadiness, setSupplyReadiness] =
    useState<EventSupplyReadiness | null>(null);
  const [query, setQuery] = useState("");
  const [externalQuery, setExternalQuery] = useState("");
  const [filter, setFilter] =
    useState<EventPublishingFilter>("launchCities");
  const [externalFilter, setExternalFilter] =
    useState<ExternalEventSupplyFilter>("reviewOpen");
  const [view, setView] = useState<EventPublishingView>("list");
  const [eventId, setEventId] = useState("");
  const [event, setEvent] = useState<AdminEventDetails | null>(null);
  const [form, setForm] = useState<EventPublishingFormState | null>(null);
  const [isListLoading, setIsListLoading] = useState(false);
  const [isExternalListLoading, setIsExternalListLoading] = useState(false);
  const [isSupplyReadinessLoading, setIsSupplyReadinessLoading] =
    useState(false);
  const [isDetailLoading, setIsDetailLoading] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [publishingExternalActionId, setPublishingExternalActionId] =
    useState<string | null>(null);
  const listPayload = useMemo(
    () => buildEventListPayload(filter, query),
    [filter, query]
  );
  const externalListPayload = useMemo(
    () => buildExternalEventListPayload(externalFilter, externalQuery),
    [externalFilter, externalQuery]
  );

  const refreshList = useCallback(async () => {
    setIsListLoading(true);
    try {
      const response = await listEventProfiles(listPayload);
      setRows(response.rows);
      setListGeneratedAt(response.generatedAt);
    } catch (error) {
      onError(messageFromError(error, "Unable to load event profiles."));
    } finally {
      setIsListLoading(false);
    }
  }, [listPayload, onError]);

  const refreshExternalList = useCallback(async () => {
    setIsExternalListLoading(true);
    try {
      const response = await listExternalEventProfiles(externalListPayload);
      setExternalRows(response.rows);
      setExternalListGeneratedAt(response.generatedAt);
    } catch (error) {
      onError(messageFromError(error, "Unable to load external event supply."));
    } finally {
      setIsExternalListLoading(false);
    }
  }, [externalListPayload, onError]);

  const refreshSupplyReadiness = useCallback(async () => {
    setIsSupplyReadinessLoading(true);
    try {
      setSupplyReadiness(await loadEventSupplyReadiness());
    } catch (error) {
      onError(messageFromError(error, "Unable to load event import readiness."));
    } finally {
      setIsSupplyReadinessLoading(false);
    }
  }, [onError]);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      void refreshList();
    }, query.trim() ? 250 : 0);
    return () => window.clearTimeout(timer);
  }, [query, refreshList]);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      void refreshExternalList();
    }, externalQuery.trim() ? 250 : 0);
    return () => window.clearTimeout(timer);
  }, [externalQuery, refreshExternalList]);

  useEffect(() => {
    void refreshSupplyReadiness();
  }, [refreshSupplyReadiness]);

  const loadEvent = useCallback(async (nextEventId = eventId) => {
    const normalizedEventId = nextEventId.trim();
    if (!normalizedEventId) {
      onError("Enter an events/{id} document id before loading.");
      return;
    }
    setIsDetailLoading(true);
    try {
      const response = await loadEventProfile({eventId: normalizedEventId});
      setEvent(response.event);
      setForm(formFromEventProfile(response.event));
      setEventId(response.event.eventId);
      onError(null);
    } catch (error) {
      onError(messageFromError(error, "Unable to load event profile."));
    } finally {
      setIsDetailLoading(false);
    }
  }, [eventId, onError]);

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
    setIsSaving(true);
    try {
      const result = await saveEventProfile(payload);
      const refreshed = await loadEventProfile({eventId: result.eventId});
      setEvent(refreshed.event);
      setForm(formFromEventProfile(refreshed.event));
      await refreshList();
      onError(null);
      onNotice(`Saved ${result.updatedFieldCount} event field updates.`);
      return true;
    } catch (error) {
      onError(messageFromError(error, "Unable to save event profile."));
      return false;
    } finally {
      setIsSaving(false);
    }
  }, [event, form, onError, onNotice, refreshList]);

  const publishExternalEvent = useCallback(async (
    publishRequest: ExternalEventPublishRequest
  ) => {
    if (!publishRequest.reviewNote.trim()) {
      onError("Add a review note before publishing external supply.");
      return false;
    }
    setPublishingExternalActionId(publishRequest.sourceActionId);
    try {
      const result = await publishExternalEventProfile({
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
    } finally {
      setPublishingExternalActionId(null);
    }
  }, [onError, onNotice, refreshExternalList, refreshSupplyReadiness]);

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
    isDetailLoading,
    isExternalListLoading,
    isListLoading,
    isSaving,
    isSupplyReadinessLoading,
    listGeneratedAt,
    publishingExternalActionId,
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
