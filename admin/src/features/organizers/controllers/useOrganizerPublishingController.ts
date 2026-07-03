import {useMutation, useQuery, useQueryClient} from "@tanstack/react-query";
import {useCallback, useEffect, useMemo, useState} from "react";
import type {
  AdminClubDetails,
  AdminClubListRow,
  AdminListClubDetailsPayload,
} from "../../../shared/types/adminTypes";
import {
  listOrganizerProfiles,
  loadOrganizerProfile,
  publishOrganizerProfile,
  saveOrganizerProfile,
} from "../api/organizerPublishingRepository";
import {
  buildOrganizerPublishPayload,
  buildOrganizerSavePayload,
  completePublishChecklist,
  diffOrganizerProfile,
  emptyPublishChecklist,
  hasBlockingIssues,
  type OrganizerDiffRow,
  type OrganizerPublishingFormState,
  type OrganizerValidationIssue,
  type PublishChecklistState,
  formFromOrganizerProfile,
  validateOrganizerPublishingForm,
} from "./organizerPublishingHelpers";
import {
  isLaunchMarketId,
  launchMarketIds,
} from "../../../shared/config/launchMarkets";
import {adminQueryKeys} from "../../../shared/query/queryKeys";

export type OrganizerPublishingFilter =
  | "launchCities"
  | "all"
  | "needsPublish"
  | "published"
  | "appHidden"
  | "routeIssues"
  | "searchIssues";

export type OrganizerPublishingView = "list" | "detail";

export function useOrganizerPublishingController({
  selectedClubId,
  onBackToList,
  onError,
  onNotice,
  onSelectClubId,
}: {
  selectedClubId?: string | null;
  onBackToList?: () => void;
  onError: (message: string | null) => void;
  onNotice: (message: string | null) => void;
  onSelectClubId?: (clubId: string) => void;
}) {
  const queryClient = useQueryClient();
  const [query, setQuery] = useState("");
  const debouncedQuery = useDebouncedValue(query, query.trim() ? 250 : 0);
  const [filter, setFilter] =
    useState<OrganizerPublishingFilter>("launchCities");
  const [clubId, setClubId] = useState("");
  const [club, setClub] = useState<AdminClubDetails | null>(null);
  const [form, setForm] = useState<OrganizerPublishingFormState | null>(null);
  const [checklist, setChecklist] =
    useState<PublishChecklistState>(emptyPublishChecklist);
  const listPayload = useMemo(
    () => buildOrganizerListPayload(filter, debouncedQuery),
    [debouncedQuery, filter]
  );
  const listQueryKey = adminQueryKeys.organizers.list(JSON.stringify(listPayload));
  const detailClubId = selectedClubId?.trim() ?? "";
  const view: OrganizerPublishingView = detailClubId ? "detail" : "list";
  const detailQueryKey = detailClubId ?
    adminQueryKeys.organizers.detail(detailClubId) :
    adminQueryKeys.organizers.detail("__none__");
  const listQuery = useQuery({
    queryKey: listQueryKey,
    queryFn: () => listOrganizerProfiles(listPayload),
  });
  const detailQuery = useQuery({
    enabled: Boolean(detailClubId),
    queryKey: detailQueryKey,
    queryFn: () => loadOrganizerProfile({clubId: detailClubId}),
  });
  const saveMutation = useMutation({
    mutationFn: saveOrganizerProfile,
  });
  const publishMutation = useMutation({
    mutationFn: publishOrganizerProfile,
  });
  const rows = listQuery.data?.rows ?? [];
  const listGeneratedAt = listQuery.data?.generatedAt ?? null;

  const refreshList = useCallback(async () => {
    await listQuery.refetch();
  }, [listQuery]);

  useEffect(() => {
    if (!listQuery.error) return;
    onError(messageFromError(listQuery.error, "Unable to load organizer profiles."));
  }, [listQuery.error, onError]);

  useEffect(() => {
    if (!detailQuery.error) return;
    onError(messageFromError(detailQuery.error, "Unable to load organizer profile."));
  }, [detailQuery.error, onError]);

  useEffect(() => {
    if (!detailQuery.data) return;
    setClub(detailQuery.data.club);
    setForm(formFromOrganizerProfile(detailQuery.data.club));
    setClubId(detailQuery.data.club.clubId);
    setChecklist(emptyPublishChecklist);
    onError(null);
  }, [detailQuery.data, onError]);

  const loadClub = useCallback(async (nextClubId = clubId) => {
    const normalizedClubId = nextClubId.trim();
    if (!normalizedClubId) {
      onError("Enter a clubs/{id} document id before loading.");
      return;
    }
    if (onSelectClubId && normalizedClubId !== detailClubId) {
      onSelectClubId(normalizedClubId);
      onError(null);
      return;
    }
    try {
      const response = await queryClient.fetchQuery({
        queryKey: adminQueryKeys.organizers.detail(normalizedClubId),
        queryFn: () => loadOrganizerProfile({clubId: normalizedClubId}),
        staleTime: 0,
      });
      setClub(response.club);
      setForm(formFromOrganizerProfile(response.club));
      setClubId(response.club.clubId);
      setChecklist(emptyPublishChecklist);
      onError(null);
    } catch (error) {
      onError(messageFromError(error, "Unable to load organizer profile."));
    }
  }, [clubId, detailClubId, onError, onSelectClubId, queryClient]);

  useEffect(() => {
    const routeClubId = selectedClubId?.trim() ?? "";
    if (!routeClubId) {
      setClubId("");
      setClub(null);
      setForm(null);
      setChecklist(emptyPublishChecklist);
      return;
    }
    setClubId(routeClubId);
  }, [selectedClubId]);

  const selectOrganizer = useCallback((nextClubId: string) => {
    setClubId(nextClubId);
    if (onSelectClubId) {
      onSelectClubId(nextClubId);
      return;
    }
    void loadClub(nextClubId);
  }, [loadClub, onSelectClubId]);

  const backToList = useCallback(() => {
    setClub(null);
    setForm(null);
    setClubId("");
    setChecklist(emptyPublishChecklist);
    onError(null);
    onBackToList?.();
  }, [onBackToList, onError]);

  const diffRows = useMemo(
    () => diffOrganizerProfile(club, form),
    [club, form]
  );
  const validationIssues = useMemo(
    () => validateOrganizerPublishingForm(
      form,
      {requireReviewNote: diffRows.length > 0}
    ),
    [diffRows.length, form]
  );
  const publishingIssues = useMemo(
    () => validateOrganizerPublishingForm(
      form,
      {publishing: true, requireReviewNote: true}
    ),
    [form]
  );

  const save = useCallback(async () => {
    if (!club || !form) {
      onError("Load an organizer before saving.");
      return false;
    }
    const payload = buildOrganizerSavePayload(club, form);
    if (Object.keys(payload.fields).length === 0) {
      onNotice("No organizer changes to save.");
      return true;
    }
    const issues = validateOrganizerPublishingForm(form, {
      requireReviewNote: true,
    });
    if (hasBlockingIssues(issues)) {
      onError(issues.find((issue) => issue.severity === "blocker")?.detail ??
        "Resolve organizer validation issues before saving.");
      return false;
    }
    try {
      const result = await saveMutation.mutateAsync(payload);
      const refreshed = await queryClient.fetchQuery({
        queryKey: adminQueryKeys.organizers.detail(result.clubId),
        queryFn: () => loadOrganizerProfile({clubId: result.clubId}),
        staleTime: 0,
      });
      setClub(refreshed.club);
      setForm(formFromOrganizerProfile(refreshed.club));
      await refreshList();
      onError(null);
      onNotice(`Saved ${result.updatedFieldCount} organizer field updates.`);
      return true;
    } catch (error) {
      onError(messageFromError(error, "Unable to save organizer profile."));
      return false;
    }
  }, [club, form, onError, onNotice, queryClient, refreshList, saveMutation]);

  const saveAndPublish = useCallback(async () => {
    if (!club || !form) {
      onError("Load an organizer before publishing.");
      return;
    }
    const issues = validateOrganizerPublishingForm(form, {
      publishing: true,
      requireReviewNote: true,
    });
    if (hasBlockingIssues(issues)) {
      onError(issues.find((issue) => issue.severity === "blocker")?.detail ??
        "Resolve organizer validation issues before publishing.");
      return;
    }
    if (!completePublishChecklist(checklist)) {
      onError("Complete the publish checklist before indexing this profile.");
      return;
    }
    try {
      const saved = await save();
      if (!saved) return;
      const result = await publishMutation.mutateAsync(
        buildOrganizerPublishPayload(form, checklist)
      );
      const refreshed = await queryClient.fetchQuery({
        queryKey: adminQueryKeys.organizers.detail(result.clubId),
        queryFn: () => loadOrganizerProfile({clubId: result.clubId}),
        staleTime: 0,
      });
      setClub(refreshed.club);
      setForm(formFromOrganizerProfile(refreshed.club));
      setChecklist(emptyPublishChecklist);
      await refreshList();
      onError(null);
      onNotice(
        `${refreshed.club.name} is ${result.publishStatus} with ` +
          `${result.robots}.`
      );
    } catch (error) {
      onError(messageFromError(error, "Unable to publish organizer profile."));
    }
  }, [
    checklist,
    club,
    form,
    onError,
    onNotice,
    publishMutation,
    queryClient,
    refreshList,
    save,
  ]);

  return {
    backToList,
    checklist,
    club,
    clubId,
    diffRows,
    filter,
    form,
    isDetailLoading: detailQuery.isFetching,
    isListLoading: listQuery.isFetching,
    isPublishing: publishMutation.isPending,
    isSaving: saveMutation.isPending,
    listGeneratedAt,
    publishingIssues,
    query,
    rows,
    validationIssues,
    view,
    filteredRows: filterOrganizerRows(rows, filter),
    completeChecklist: completePublishChecklist(checklist),
    refreshList,
    save,
    saveAndPublish,
    selectOrganizer,
    setChecklist,
    setClubId,
    setFilter,
    setForm,
    setQuery,
  };
}

function useDebouncedValue(value: string, delayMs: number) {
  const [debouncedValue, setDebouncedValue] = useState(value);
  useEffect(() => {
    const timer = window.setTimeout(() => setDebouncedValue(value), delayMs);
    return () => window.clearTimeout(timer);
  }, [delayMs, value]);
  return debouncedValue;
}

export function filterOrganizerRows(
  rows: AdminClubListRow[],
  filter: OrganizerPublishingFilter
): AdminClubListRow[] {
  return rows.filter((row) => {
    if (filter === "launchCities" && !isLaunchMarketId(row.citySlug)) {
      return false;
    }
    if (filter === "needsPublish" && !organizerNeedsPublish(row)) {
      return false;
    }
    if (filter === "published" && row.publishStatus !== "published") {
      return false;
    }
    if (filter === "appHidden" && row.appVisibility !== "hidden") {
      return false;
    }
    if (filter === "routeIssues" &&
        row.routeStatus === "valid" &&
        row.routeReservationStatus === "reserved") {
      return false;
    }
    if (filter === "searchIssues" && row.searchIndexStatus === "indexed") {
      return false;
    }
    return true;
  });
}

export function organizerNeedsPublish(row: AdminClubListRow): boolean {
  const publishableSourceConfidence =
    row.sourceConfidence === "high" ||
    row.sourceConfidence === "ownerVerified";
  return row.routeStatus !== "valid" ||
    row.routeReservationStatus !== "reserved" ||
    row.searchIndexStatus !== "indexed" ||
    row.publishStatus !== "published" ||
    row.indexStatus === "noindex" ||
    !publishableSourceConfidence ||
    row.verificationStatus === "unverified";
}

export function countBlockingIssues(
  issues: OrganizerValidationIssue[]
): number {
  return issues.filter((issue) => issue.severity === "blocker").length;
}

export function countDiffRows(rows: OrganizerDiffRow[]): number {
  return rows.length;
}

export function buildOrganizerListPayload(
  filter: OrganizerPublishingFilter,
  query: string
): AdminListClubDetailsPayload {
  const payload: AdminListClubDetailsPayload = {
    limit: 100,
    query: query.trim() || null,
  };
  if (filter === "launchCities") {
    payload.citySlugs = Array.from(launchMarketIds);
  }
  if (filter === "published") payload.publishStatus = "published";
  if (filter === "appHidden") payload.appVisibility = "hidden";
  return payload;
}

function messageFromError(error: unknown, fallback: string): string {
  return error instanceof Error ? error.message : fallback;
}

export type OrganizerPublishingController =
  ReturnType<typeof useOrganizerPublishingController>;
