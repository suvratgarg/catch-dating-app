import {useCallback, useEffect, useMemo, useState} from "react";
import type {
  AdminSafetyTriageAssignment,
  AdminSafetyTriageDecision,
  AdminQueueItem,
  AdminSafetyTriageDetails,
} from "../../../shared/types/adminTypes";
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
  const [rows, setRows] = useState<SafetyTriageRow[]>([]);
  const [metrics, setMetrics] = useState<SafetyTriageMetrics>({
    reports: 0,
    moderation: 0,
    eventReports: 0,
    highPriority: 0,
  });
  const [selectedTargetPath, setSelectedTargetPath] = useState<string | null>(
    null
  );
  const [queueFilter, setQueueFilter] = useState<SafetyQueueKind>("all");
  const [query, setQuery] = useState("");
  const [generatedAt, setGeneratedAt] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [detailsByPath, setDetailsByPath] =
    useState<Record<string, AdminSafetyTriageDetails>>({});
  const [detailTargetPathLoading, setDetailTargetPathLoading] =
    useState<string | null>(null);
  const [decisionForm, setDecisionForm] =
    useState<SafetyDecisionFormState>({note: ""});
  const [assignmentForm, setAssignmentForm] =
    useState<SafetyAssignmentFormState>({assigneeUid: "", note: ""});
  const [decisionInFlight, setDecisionInFlight] =
    useState<AdminSafetyTriageDecision | null>(null);
  const [assignmentInFlight, setAssignmentInFlight] = useState(false);
  const [recentDecisions, setRecentDecisions] =
    useState<SafetyDecisionRecord[]>([]);
  const [recentAssignments, setRecentAssignments] =
    useState<SafetyAssignmentRecord[]>([]);

  const refresh = useCallback(async () => {
    setIsLoading(true);
    try {
      const snapshot = await loadSafetyTriageSnapshot();
      const nextRows = buildSafetyRows(snapshot);
      setRows(nextRows);
      setMetrics(safetyMetrics(nextRows));
      setGeneratedAt(snapshot.generatedAt);
      setSelectedTargetPath((current) => {
        if (current && nextRows.some((row) => row.targetPath === current)) {
          return current;
        }
        return null;
      });
      onError(null);
    } catch (error) {
      onError(messageFromError(error, "Unable to load safety queues."));
    } finally {
      setIsLoading(false);
    }
  }, [onError]);

  useEffect(() => {
    void refresh();
  }, [refresh]);

  const filteredRows = useMemo(
    () => filterSafetyRows(rows, queueFilter, query),
    [query, queueFilter, rows]
  );
  const selected = useMemo(
    () => rows.find((row) => row.targetPath === selectedTargetPath) ?? null,
    [rows, selectedTargetPath]
  );
  const selectedDetail = selected ?
    detailsByPath[selected.targetPath] ?? null :
    null;

  const loadDetail = useCallback(async (targetPath: string) => {
    setDetailTargetPathLoading(targetPath);
    try {
      const response = await loadSafetyTriageItem(targetPath);
      setDetailsByPath((current) => ({
        ...current,
        [targetPath]: response.item,
      }));
      onError(null);
    } catch (error) {
      onError(messageFromError(error, "Unable to load safety detail."));
    } finally {
      setDetailTargetPathLoading((current) =>
        current === targetPath ? null : current
      );
    }
  }, [onError]);

  useEffect(() => {
    if (!selected || selectedDetail) return;
    void loadDetail(selected.targetPath);
  }, [loadDetail, selected, selectedDetail]);

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
    setAssignmentInFlight(true);
    onError(null);
    onNotice(null);
    try {
      const response = await assignSafetyTriageItemOwner({
        targetPath: selected.targetPath,
        assigneeUid,
        note,
      });
      setDetailsByPath((current) => {
        const existing = current[selected.targetPath];
        if (!existing) return current;
        return {
          ...current,
          [selected.targetPath]: {
            ...existing,
            assignment: response.assignment,
          },
        };
      });
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
    } finally {
      setAssignmentInFlight(false);
    }
  }, [
    assignmentForm.assigneeUid,
    assignmentForm.note,
    assignmentValidationIssue,
    onError,
    onNotice,
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
    setDecisionInFlight(decision);
    onError(null);
    onNotice(null);
    try {
      const response = await decideSafetyTriageItemStatus({
        targetPath: selected.targetPath,
        decision,
        note,
      });
      const nextRows = rows.filter((row) =>
        row.targetPath !== selected.targetPath
      );
      setRows(nextRows);
      setMetrics(safetyMetrics(nextRows));
      setDetailsByPath((current) => {
        const next = {...current};
        delete next[selected.targetPath];
        return next;
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
    } finally {
      setDecisionInFlight(null);
    }
  }, [decisionForm.note, onError, onNotice, rows, selected]);

  return {
    assignmentForm,
    assignmentInFlight,
    assignmentValidationIssue,
    decisionForm,
    decisionInFlight,
    decisionValidationIssue,
    filteredRows,
    generatedAt,
    isDetailLoading: selected ?
      detailTargetPathLoading === selected.targetPath :
      false,
    isLoading,
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
