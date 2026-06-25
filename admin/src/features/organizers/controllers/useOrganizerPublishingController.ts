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

export type OrganizerPublishingFilter =
  | "launchCities"
  | "all"
  | "needsPublish"
  | "published"
  | "appHidden"
  | "routeIssues"
  | "searchIssues";

const launchCitySlugs = new Set(["indore", "mumbai"]);

export function useOrganizerPublishingController({
  onError,
  onNotice,
}: {
  onError: (message: string | null) => void;
  onNotice: (message: string | null) => void;
}) {
  const [rows, setRows] = useState<AdminClubListRow[]>([]);
  const [listGeneratedAt, setListGeneratedAt] = useState<string | null>(null);
  const [query, setQuery] = useState("");
  const [filter, setFilter] =
    useState<OrganizerPublishingFilter>("launchCities");
  const [clubId, setClubId] = useState("");
  const [club, setClub] = useState<AdminClubDetails | null>(null);
  const [form, setForm] = useState<OrganizerPublishingFormState | null>(null);
  const [checklist, setChecklist] =
    useState<PublishChecklistState>(emptyPublishChecklist);
  const [isListLoading, setIsListLoading] = useState(false);
  const [isDetailLoading, setIsDetailLoading] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [isPublishing, setIsPublishing] = useState(false);
  const listPayload = useMemo(
    () => buildOrganizerListPayload(filter, query),
    [filter, query]
  );

  const refreshList = useCallback(async () => {
    setIsListLoading(true);
    try {
      const response = await listOrganizerProfiles(listPayload);
      setRows(response.rows);
      setListGeneratedAt(response.generatedAt);
    } catch (error) {
      onError(messageFromError(error, "Unable to load organizer profiles."));
    } finally {
      setIsListLoading(false);
    }
  }, [listPayload, onError]);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      void refreshList();
    }, query.trim() ? 250 : 0);
    return () => window.clearTimeout(timer);
  }, [query, refreshList]);

  const loadClub = useCallback(async (nextClubId = clubId) => {
    const normalizedClubId = nextClubId.trim();
    if (!normalizedClubId) {
      onError("Enter a clubs/{id} document id before loading.");
      return;
    }
    setIsDetailLoading(true);
    try {
      const response = await loadOrganizerProfile({clubId: normalizedClubId});
      setClub(response.club);
      setForm(formFromOrganizerProfile(response.club));
      setClubId(response.club.clubId);
      setChecklist(emptyPublishChecklist);
      onError(null);
    } catch (error) {
      onError(messageFromError(error, "Unable to load organizer profile."));
    } finally {
      setIsDetailLoading(false);
    }
  }, [clubId, onError]);

  const selectOrganizer = useCallback((nextClubId: string) => {
    setClubId(nextClubId);
    void loadClub(nextClubId);
  }, [loadClub]);

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
    setIsSaving(true);
    try {
      const result = await saveOrganizerProfile(payload);
      const refreshed = await loadOrganizerProfile({clubId: result.clubId});
      setClub(refreshed.club);
      setForm(formFromOrganizerProfile(refreshed.club));
      await refreshList();
      onError(null);
      onNotice(`Saved ${result.updatedFieldCount} organizer field updates.`);
      return true;
    } catch (error) {
      onError(messageFromError(error, "Unable to save organizer profile."));
      return false;
    } finally {
      setIsSaving(false);
    }
  }, [club, form, onError, onNotice, refreshList]);

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
    setIsPublishing(true);
    try {
      const saved = await save();
      if (!saved) return;
      const result = await publishOrganizerProfile(
        buildOrganizerPublishPayload(form, checklist)
      );
      const refreshed = await loadOrganizerProfile({clubId: result.clubId});
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
    } finally {
      setIsPublishing(false);
    }
  }, [checklist, club, form, onError, onNotice, refreshList, save]);

  return {
    checklist,
    club,
    clubId,
    diffRows,
    filter,
    form,
    isDetailLoading,
    isListLoading,
    isPublishing,
    isSaving,
    listGeneratedAt,
    publishingIssues,
    query,
    rows,
    validationIssues,
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

export function filterOrganizerRows(
  rows: AdminClubListRow[],
  filter: OrganizerPublishingFilter
): AdminClubListRow[] {
  return rows.filter((row) => {
    if (filter === "launchCities" && !launchCitySlugs.has(row.citySlug ?? "")) {
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
    payload.citySlugs = Array.from(launchCitySlugs);
  }
  if (filter === "published") payload.publishStatus = "published";
  if (filter === "appHidden") payload.appVisibility = "hidden";
  return payload;
}

function messageFromError(error: unknown, fallback: string): string {
  return error instanceof Error ? error.message : fallback;
}
