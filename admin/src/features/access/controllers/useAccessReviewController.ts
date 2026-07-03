import {useMutation, useQuery, useQueryClient} from "@tanstack/react-query";
import {useCallback, useEffect, useMemo, useState} from "react";
import type {
  AccessApplicationDecision,
  AdminAccessApplicationDetails,
  AdminQueueItem,
} from "../../../shared/types/adminTypes";
import {adminQueryKeys} from "../../../shared/query/queryKeys";
import {
  decideAccessReview,
  listAccessApplications,
  loadAccessApplicationDetails,
} from "../api/accessReviewRepository";

export interface AccessReviewFormState {
  note: string;
  cohortId: string;
}

export interface AccessRecentDecision {
  applicationUid: string;
  title: string;
  decision: AccessApplicationDecision;
  status: "approvedForProfile" | "notSelectedYet";
}

export interface AccessReviewController {
  decisionInFlight: AccessApplicationDecision | null;
  filteredRows: AdminQueueItem[];
  form: AccessReviewFormState;
  isDetailLoading: boolean;
  isLoading: boolean;
  query: string;
  recentDecisions: AccessRecentDecision[];
  rows: AdminQueueItem[];
  selected: AdminQueueItem | null;
  selectedDetails: AdminAccessApplicationDetails | null;
  validationIssue: string | null;
  decide: (decision: AccessApplicationDecision) => Promise<boolean>;
  refresh: () => Promise<void>;
  select: (row: AdminQueueItem) => void;
  setForm: (form: AccessReviewFormState) => void;
  setQuery: (query: string) => void;
}

export function useAccessReviewController({
  onError,
  onNotice,
}: {
  onError: (message: string | null) => void;
  onNotice: (message: string | null) => void;
}): AccessReviewController {
  const queryClient = useQueryClient();
  const [selectedTargetPath, setSelectedTargetPath] = useState<string | null>(
    null
  );
  const [query, setQuery] = useState("");
  const [form, setForm] = useState<AccessReviewFormState>({
    note: "",
    cohortId: "",
  });
  const [recentDecisions, setRecentDecisions] = useState<AccessRecentDecision[]>(
    []
  );

  const listQuery = useQuery({
    queryKey: adminQueryKeys.access.applications(),
    queryFn: listAccessApplications,
  });
  const rows = listQuery.data ?? [];

  const filteredRows = useMemo(
    () => filterAccessRows(rows, query),
    [query, rows]
  );
  const selected = useMemo(
    () => rows.find((row) => row.targetPath === selectedTargetPath) ?? null,
    [rows, selectedTargetPath]
  );
  const selectedApplicationUid = selected ?
    applicationUidFromTargetPath(selected.targetPath) :
    null;
  const detailQuery = useQuery({
    enabled: Boolean(selectedApplicationUid),
    queryKey: adminQueryKeys.access.detail(selectedApplicationUid ?? "none"),
    queryFn: () => loadAccessApplicationDetails({
      applicationUid: selectedApplicationUid ?? "",
    }),
  });
  const decideMutation = useMutation({
    mutationFn: decideAccessReview,
  });
  const validationIssue = validateAccessReview(selected, form);

  useEffect(() => {
    if (listQuery.isError) {
      onError(messageFromError(
        listQuery.error,
        "Unable to load access applications."
      ));
      return;
    }
    if (listQuery.isSuccess) {
      onError(null);
    }
  }, [listQuery.error, listQuery.isError, listQuery.isSuccess, onError]);

  useEffect(() => {
    if (!detailQuery.isError) return;
    onError(messageFromError(
      detailQuery.error,
      "Unable to load access application detail."
    ));
  }, [detailQuery.error, detailQuery.isError, onError]);

  useEffect(() => {
    setSelectedTargetPath((current) => {
      if (current && rows.some((row) => row.targetPath === current)) {
        return current;
      }
      return null;
    });
  }, [rows]);

  const select = useCallback((row: AdminQueueItem) => {
    setSelectedTargetPath(row.targetPath);
    setForm({note: "", cohortId: ""});
    onError(null);
    const applicationUid = applicationUidFromTargetPath(row.targetPath);
    if (!applicationUid) {
      onError("Cannot load access application detail without a valid target.");
    }
  }, [onError]);

  const decide = useCallback(async (decision: AccessApplicationDecision) => {
    if (!selected) {
      onError("Select an access application before deciding.");
      return false;
    }
    const applicationUid = applicationUidFromTargetPath(selected.targetPath);
    if (!applicationUid) {
      onError("Cannot decide an access application without a valid target.");
      return false;
    }
    const issue = validateAccessReview(selected, form);
    if (issue) {
      onError(issue);
      return false;
    }
    try {
      const result = await decideMutation.mutateAsync({
        applicationUid,
        decision,
        note: form.note.trim(),
        cohortId: nullableText(form.cohortId),
      });
      queryClient.setQueryData<AdminQueueItem[]>(
        adminQueryKeys.access.applications(),
        (current) =>
          (current ?? []).filter((row) => row.targetPath !== selected.targetPath)
      );
      await queryClient.invalidateQueries({
        queryKey: adminQueryKeys.access.applications(),
      });
      setRecentDecisions((current) => [{
        applicationUid,
        title: selected.title,
        decision,
        status: result.status,
      }, ...current].slice(0, 6));
      setSelectedTargetPath(null);
      setForm({note: "", cohortId: ""});
      onError(null);
      onNotice(
        `${decision === "approve" ? "Approved" : "Denied"} ${selected.title}.`
      );
      return true;
    } catch (error) {
      onError(messageFromError(error, "Unable to decide access application."));
      return false;
    }
  }, [decideMutation, form, onError, onNotice, queryClient, selected]);

  const refresh = useCallback(async () => {
    await listQuery.refetch();
  }, [listQuery]);

  return {
    decisionInFlight: decideMutation.isPending ?
      decideMutation.variables?.decision ?? null :
      null,
    filteredRows,
    form,
    isLoading: listQuery.isPending || listQuery.isFetching,
    isDetailLoading: Boolean(selected) &&
      (detailQuery.isPending || detailQuery.isFetching),
    query,
    recentDecisions,
    rows,
    selected,
    selectedDetails: detailQuery.data?.application ?? null,
    validationIssue,
    decide,
    refresh,
    select,
    setForm,
    setQuery,
  };
}

export function applicationUidFromTargetPath(targetPath: string): string | null {
  const [collection, uid, extra] = targetPath.split("/");
  if (collection !== "accessApplications" || !uid || extra) return null;
  return uid;
}

function filterAccessRows(
  rows: AdminQueueItem[],
  query: string
): AdminQueueItem[] {
  const normalizedQuery = query.trim().toLowerCase();
  if (!normalizedQuery) return rows;
  const tokens = normalizedQuery.split(/\s+/u).filter(Boolean);
  return rows.filter((row) => {
    const haystack = [
      row.id,
      row.title,
      row.detail,
      row.status,
      row.targetPath,
      row.createdAt,
    ].join(" ").toLowerCase();
    return tokens.every((token) => haystack.includes(token));
  });
}

function validateAccessReview(
  selected: AdminQueueItem | null,
  form: AccessReviewFormState
): string | null {
  if (!selected) return "Select an access application before deciding.";
  if (!form.note.trim()) {
    return "Add a review note before approving or denying access.";
  }
  if (form.note.trim().length > 1000) {
    return "Review note must be 1000 characters or fewer.";
  }
  if (form.cohortId.trim().length > 120) {
    return "Cohort id must be 120 characters or fewer.";
  }
  return null;
}

function nullableText(value: string): string | null {
  const trimmed = value.trim();
  return trimmed.length === 0 ? null : trimmed;
}

function messageFromError(error: unknown, fallback: string): string {
  if (error && typeof error === "object" && "message" in error) {
    const message = (error as {message?: unknown}).message;
    if (typeof message === "string" && message.trim()) return message;
  }
  return fallback;
}
