import {useMutation, useQuery, useQueryClient} from "@tanstack/react-query";
import {useCallback, useEffect, useMemo, useState} from "react";
import type {
  AdminGetSafetyTriageDetailsResponse,
  AdminOverviewResponse,
  AdminSafetyTriageAssignment,
  AdminSafetyTriageDecision,
  AdminQueueItem,
} from "../../../shared/types/adminTypes";
import {adminQueryKeys} from "../../../shared/query/queryKeys";
import {
  assignSafetyTriageItemOwner,
  decideSafetyTriageItemStatus,
  loadSafetyTriageItem,
  loadSafetyTriageSnapshot,
} from "../api/safetyTriageRepository";

export type SafetyQueueKind =
  | "all"
  | "reports"
  | "moderation"
  | "event";

export interface SafetyTriageRow extends AdminQueueItem {
  queueKind: Exclude<SafetyQueueKind, "all">;
  queueLabel: string;
  priority: "high" | "medium" | "watch";
  routeOwner: string;
}

export interface SafetyTriageMetrics {
  reports: number;
  moderation: number;
  eventReports: number;
  highPriority: number;
}

export interface SafetyDecisionFormState {
  note: string;
}

export interface SafetyAssignmentFormState {
  assigneeUid: string;
  note: string;
}

export interface SafetyDecisionRecord {
  targetPath: string;
  decision: AdminSafetyTriageDecision;
  status: "reviewed" | "dismissed";
  note: string;
}

export interface SafetyAssignmentRecord {
  targetPath: string;
  assignment: AdminSafetyTriageAssignment;
  note: string;
}

export function useSafetyTriageController({
  onError,
  onNotice,
}: {
  onError: (message: string | null) => void;
  onNotice: (message: string | null) => void;
}) {
  const queryClient = useQueryClient();
  const [selectedTargetPath, setSelectedTargetPath] = useState<string | null>(
    null
  );
  const [queueFilter, setQueueFilter] = useState<SafetyQueueKind>("all");
  const [query, setQuery] = useState("");
  const [decisionForm, setDecisionForm] =
    useState<SafetyDecisionFormState>({note: ""});
  const [assignmentForm, setAssignmentForm] =
    useState<SafetyAssignmentFormState>({assigneeUid: "", note: ""});
  const [recentDecisions, setRecentDecisions] =
    useState<SafetyDecisionRecord[]>([]);
  const [recentAssignments, setRecentAssignments] =
    useState<SafetyAssignmentRecord[]>([]);

  const queueQueryKey = adminQueryKeys.safety.queue();
  const queueQuery = useQuery({
    queryKey: queueQueryKey,
    queryFn: loadSafetyTriageSnapshot,
    placeholderData: (previousData) => previousData,
  });
  const rows = useMemo(
    () => queueQuery.data ? buildSafetyRows(queueQuery.data) : [],
    [queueQuery.data]
  );
  const metrics = useMemo(() => safetyMetrics(rows), [rows]);
  const generatedAt = queueQuery.data?.generatedAt ?? null;
  const selected = useMemo(
    () => rows.find((row) => row.targetPath === selectedTargetPath) ?? null,
    [rows, selectedTargetPath]
  );
  const detailQuery = useQuery({
    enabled: Boolean(selectedTargetPath),
    queryKey: adminQueryKeys.safety.detail(selectedTargetPath ?? "__none__"),
    queryFn: () => {
      if (!selectedTargetPath) {
        throw new Error("Cannot load safety detail without a target path.");
      }
      return loadSafetyTriageItem(selectedTargetPath);
    },
  });
  const selectedDetail = selected ? detailQuery.data?.item ?? null : null;
  const assignmentMutation = useMutation({
    mutationFn: assignSafetyTriageItemOwner,
  });
  const decisionMutation = useMutation({
    mutationFn: decideSafetyTriageItemStatus,
  });

  const refresh = useCallback(async () => {
    const result = await queueQuery.refetch();
    if (result.error) {
      onError(messageFromError(result.error, "Unable to load safety queues."));
      return false;
    }
    onError(null);
    return true;
  }, [onError, queueQuery]);

  useEffect(() => {
    if (queueQuery.isError) {
      onError(messageFromError(
        queueQuery.error,
        "Unable to load safety queues."
      ));
      return;
    }
    if (queueQuery.isSuccess) onError(null);
  }, [onError, queueQuery.error, queueQuery.isError, queueQuery.isSuccess]);

  useEffect(() => {
    if (!detailQuery.isError) return;
    onError(messageFromError(
      detailQuery.error,
      "Unable to load safety detail."
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

  const filteredRows = useMemo(
    () => filterSafetyRows(rows, queueFilter, query),
    [query, queueFilter, rows]
  );

  useEffect(() => {
    if (!selectedDetail) return;
    setAssignmentForm((current) => {
      if (current.note) return current;
      const assigneeUid = selectedDetail.assignment.assigneeUid ?? "";
      if (current.assigneeUid === assigneeUid) return current;
      return {
        ...current,
        assigneeUid,
      };
    });
  }, [selectedDetail]);

  const select = useCallback((row: SafetyTriageRow) => {
    setSelectedTargetPath(row.targetPath);
    setDecisionForm({note: ""});
    setAssignmentForm({assigneeUid: "", note: ""});
    onError(null);
    onNotice(null);
  }, [onError, onNotice]);

  const decisionValidationIssue = useMemo(() => {
    if (!selected) return "Select a safety queue item before deciding.";
    const note = decisionForm.note.trim();
    if (!note) return "Add a review note before deciding this item.";
    if (note.length > 1000) return "Review note must be 1000 characters or fewer.";
    return null;
  }, [decisionForm.note, selected]);

  const assignmentValidationIssue = useMemo(() => {
    if (!selected) return "Select a safety queue item before assigning.";
    const assigneeUid = assignmentForm.assigneeUid.trim();
    if (assigneeUid && !/^[A-Za-z0-9_-]{3,128}$/u.test(assigneeUid)) {
      return "Assignee uid must be 3-128 letters, numbers, underscores, or hyphens.";
    }
    const note = assignmentForm.note.trim();
    if (!note) return "Add an assignment note before saving.";
    if (note.length > 1000) {
      return "Assignment note must be 1000 characters or fewer.";
    }
    return null;
  }, [assignmentForm.assigneeUid, assignmentForm.note, selected]);

  const assign = useCallback(async () => {
    if (!selected) {
      onError("Select a safety queue item before assigning.");
      return false;
    }
    const issue = assignmentValidationIssue;
    if (issue) {
      onError(issue);
      return false;
    }
    const note = assignmentForm.note.trim();
    const assigneeUid = nullableText(assignmentForm.assigneeUid);
    onError(null);
    onNotice(null);
    try {
      const response = await assignmentMutation.mutateAsync({
        targetPath: selected.targetPath,
        assigneeUid,
        note,
      });
      queryClient.setQueryData<AdminGetSafetyTriageDetailsResponse>(
        adminQueryKeys.safety.detail(selected.targetPath),
        (current) => current ? {
          ...current,
          item: {
            ...current.item,
            assignment: response.assignment,
          },
        } : current
      );
      setAssignmentForm({
        assigneeUid: response.assignment.assigneeUid ?? "",
        note: "",
      });
      setRecentAssignments((current) => [{
        targetPath: response.targetPath,
        assignment: response.assignment,
        note,
      }, ...current].slice(0, 5));
      onNotice(
        response.assignment.assigneeUid ?
          `Assigned ${selected.title} to ${response.assignment.assigneeUid}.` :
          `Cleared assignment for ${selected.title}.`
      );
      return true;
    } catch (error) {
      onError(messageFromError(error, "Unable to assign safety item."));
      return false;
    }
  }, [
    assignmentForm.assigneeUid,
    assignmentForm.note,
    assignmentMutation,
    assignmentValidationIssue,
    onError,
    onNotice,
    queryClient,
    selected,
  ]);

  const decide = useCallback(async (decision: AdminSafetyTriageDecision) => {
    if (!selected) {
      onError("Select a safety queue item before deciding.");
      return false;
    }
    const note = decisionForm.note.trim();
    if (!note) {
      onError("Add a review note before deciding this item.");
      return false;
    }
    if (note.length > 1000) {
      onError("Review note must be 1000 characters or fewer.");
      return false;
    }
    onError(null);
    onNotice(null);
    try {
      const response = await decisionMutation.mutateAsync({
        targetPath: selected.targetPath,
        decision,
        note,
      });
      queryClient.setQueryData<AdminOverviewResponse>(
        queueQueryKey,
        (current) => current ?
          removeSafetyQueueItem(current, selected.targetPath) :
          current
      );
      queryClient.removeQueries({
        queryKey: adminQueryKeys.safety.detail(selected.targetPath),
      });
      setSelectedTargetPath(null);
      setDecisionForm({note: ""});
      setRecentDecisions((current) => [{
        targetPath: response.targetPath,
        decision: response.decision,
        status: response.status,
        note,
      }, ...current].slice(0, 5));
      onNotice(
        `${response.status === "reviewed" ? "Reviewed" : "Dismissed"} ${selected.title}.`
      );
      return true;
    } catch (error) {
      onError(messageFromError(error, "Unable to decide safety item."));
      return false;
    }
  }, [
    decisionForm.note,
    decisionMutation,
    onError,
    onNotice,
    queryClient,
    queueQueryKey,
    selected,
  ]);

  return {
    assignmentForm,
    assignmentInFlight: assignmentMutation.isPending,
    assignmentValidationIssue,
    decisionForm,
    decisionInFlight: decisionMutation.isPending ?
      decisionMutation.variables?.decision ?? null :
      null,
    decisionValidationIssue,
    filteredRows,
    generatedAt,
    isDetailLoading: selected ?
      detailQuery.isPending || detailQuery.isFetching :
      false,
    isLoading: queueQuery.isPending || queueQuery.isFetching,
    metrics,
    query,
    queueFilter,
    rows,
    selected,
    selectedDetail,
    recentDecisions,
    recentAssignments,
    assign,
    decide,
    refresh,
    select,
    setDecisionForm,
    setAssignmentForm,
    setQuery,
    setQueueFilter,
  };
}

export type SafetyTriageController =
  ReturnType<typeof useSafetyTriageController>;

function removeSafetyQueueItem(
  snapshot: AdminOverviewResponse,
  targetPath: string
): AdminOverviewResponse {
  return {
    ...snapshot,
    queues: {
      ...snapshot.queues,
      safetyReports: snapshot.queues.safetyReports.filter((row) =>
        row.targetPath !== targetPath
      ),
      moderationFlags: snapshot.queues.moderationFlags.filter((row) =>
        row.targetPath !== targetPath
      ),
      eventSafetyReports: snapshot.queues.eventSafetyReports.filter((row) =>
        row.targetPath !== targetPath
      ),
    },
  };
}

function buildSafetyRows(snapshot: Awaited<
  ReturnType<typeof loadSafetyTriageSnapshot>
>): SafetyTriageRow[] {
  const reportRows = snapshot.queues.safetyReports.map((row) =>
    safetyRow(row, "reports", "User reports")
  );
  const moderationRows = snapshot.queues.moderationFlags.map((row) =>
    safetyRow(row, "moderation", "Moderation flags")
  );
  const eventRows = snapshot.queues.eventSafetyReports.map((row) =>
    safetyRow(row, "event", "Event reports")
  );
  return [...reportRows, ...moderationRows, ...eventRows]
    .sort((a, b) => priorityRank(b.priority) - priorityRank(a.priority) ||
      (a.createdAt ?? "").localeCompare(b.createdAt ?? ""));
}

function safetyRow(
  row: AdminQueueItem,
  queueKind: Exclude<SafetyQueueKind, "all">,
  queueLabel: string
): SafetyTriageRow {
  return {
    ...row,
    queueKind,
    queueLabel,
    priority: priorityFor(row, queueKind),
    routeOwner: routeOwnerFor(row, queueKind),
  };
}

function safetyMetrics(rows: SafetyTriageRow[]): SafetyTriageMetrics {
  return {
    reports: rows.filter((row) => row.queueKind === "reports").length,
    moderation: rows.filter((row) => row.queueKind === "moderation").length,
    eventReports: rows.filter((row) => row.queueKind === "event").length,
    highPriority: rows.filter((row) => row.priority === "high").length,
  };
}

function filterSafetyRows(
  rows: SafetyTriageRow[],
  queueFilter: SafetyQueueKind,
  query: string
): SafetyTriageRow[] {
  const tokens = query.trim().toLowerCase().split(/\s+/u).filter(Boolean);
  return rows.filter((row) => {
    if (queueFilter !== "all" && row.queueKind !== queueFilter) return false;
    if (tokens.length === 0) return true;
    const haystack = [
      row.id,
      row.title,
      row.detail,
      row.status,
      row.targetPath,
      row.queueLabel,
      row.routeOwner,
      row.priority,
    ].join(" ").toLowerCase();
    return tokens.every((token) => haystack.includes(token));
  });
}

function priorityFor(
  row: AdminQueueItem,
  queueKind: Exclude<SafetyQueueKind, "all">
): SafetyTriageRow["priority"] {
  const haystack = `${row.title} ${row.detail} ${row.status}`.toLowerCase();
  if (queueKind === "event" || haystack.includes("harassment") ||
    haystack.includes("explicit")) {
    return "high";
  }
  if (haystack.includes("fake") || haystack.includes("pending")) {
    return "medium";
  }
  return "watch";
}

function routeOwnerFor(
  row: AdminQueueItem,
  queueKind: Exclude<SafetyQueueKind, "all">
): string {
  if (queueKind === "event") return "Event safety";
  if (queueKind === "moderation") return "Moderation";
  if (row.detail.toLowerCase().includes("chat")) return "Trust and safety";
  return "Support review";
}

function priorityRank(priority: SafetyTriageRow["priority"]): number {
  if (priority === "high") return 3;
  if (priority === "medium") return 2;
  return 1;
}

function messageFromError(error: unknown, fallback: string): string {
  if (error && typeof error === "object" && "message" in error) {
    const message = (error as {message?: unknown}).message;
    if (typeof message === "string" && message.trim()) return message;
  }
  return fallback;
}

function nullableText(value: string): string | null {
  const trimmed = value.trim();
  return trimmed.length === 0 ? null : trimmed;
}
