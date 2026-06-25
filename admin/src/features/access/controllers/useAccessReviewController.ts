import {useCallback, useEffect, useMemo, useState} from "react";
import type {
  AccessApplicationDecision,
  AdminAccessApplicationDetails,
  AdminQueueItem,
} from "../../../shared/types/adminTypes";
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

export function useAccessReviewController({
  onError,
  onNotice,
}: {
  onError: (message: string | null) => void;
  onNotice: (message: string | null) => void;
}) {
  const [rows, setRows] = useState<AdminQueueItem[]>([]);
  const [selectedTargetPath, setSelectedTargetPath] = useState<string | null>(
    null
  );
  const [query, setQuery] = useState("");
  const [form, setForm] = useState<AccessReviewFormState>({
    note: "",
    cohortId: "",
  });
  const [selectedDetails, setSelectedDetails] =
    useState<AdminAccessApplicationDetails | null>(null);
  const [recentDecisions, setRecentDecisions] = useState<AccessRecentDecision[]>(
    []
  );
  const [isLoading, setIsLoading] = useState(false);
  const [isDetailLoading, setIsDetailLoading] = useState(false);
  const [decisionInFlight, setDecisionInFlight] =
    useState<AccessApplicationDecision | null>(null);

  const refresh = useCallback(async () => {
    setIsLoading(true);
    try {
      const nextRows = await listAccessApplications();
      setRows(nextRows);
      setSelectedTargetPath((current) => {
        if (current && nextRows.some((row) => row.targetPath === current)) {
          return current;
        }
        return null;
      });
      onError(null);
    } catch (error) {
      onError(messageFromError(error, "Unable to load access applications."));
    } finally {
      setIsLoading(false);
    }
  }, [onError]);

  useEffect(() => {
    void refresh();
  }, [refresh]);

  const filteredRows = useMemo(
    () => filterAccessRows(rows, query),
    [query, rows]
  );
  const selected = useMemo(
    () => rows.find((row) => row.targetPath === selectedTargetPath) ?? null,
    [rows, selectedTargetPath]
  );
  const validationIssue = validateAccessReview(selected, form);

  const select = useCallback((row: AdminQueueItem) => {
    setSelectedTargetPath(row.targetPath);
    setForm({note: "", cohortId: ""});
    setSelectedDetails(null);
    onError(null);
    const applicationUid = applicationUidFromTargetPath(row.targetPath);
    if (!applicationUid) {
      onError("Cannot load access application detail without a valid target.");
      return;
    }
    setIsDetailLoading(true);
    void loadAccessApplicationDetails({applicationUid})
      .then((response) => {
        setSelectedDetails(response.application);
        onError(null);
      })
      .catch((error) => {
        onError(messageFromError(
          error,
          "Unable to load access application detail."
        ));
      })
      .finally(() => setIsDetailLoading(false));
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

    setDecisionInFlight(decision);
    try {
      const result = await decideAccessReview({
        applicationUid,
        decision,
        note: form.note.trim(),
        cohortId: nullableText(form.cohortId),
      });
      setRows((current) => current.filter((row) =>
        row.targetPath !== selected.targetPath
      ));
      setRecentDecisions((current) => [{
        applicationUid,
        title: selected.title,
        decision,
        status: result.status,
      }, ...current].slice(0, 6));
      setSelectedTargetPath(null);
      setSelectedDetails(null);
      setForm({note: "", cohortId: ""});
      onError(null);
      onNotice(
        `${decision === "approve" ? "Approved" : "Denied"} ${selected.title}.`
      );
      return true;
    } catch (error) {
      onError(messageFromError(error, "Unable to decide access application."));
      return false;
    } finally {
      setDecisionInFlight(null);
    }
  }, [form, onError, onNotice, selected]);

  return {
    decisionInFlight,
    filteredRows,
    form,
    isLoading,
    isDetailLoading,
    query,
    recentDecisions,
    rows,
    selected,
    selectedDetails,
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
