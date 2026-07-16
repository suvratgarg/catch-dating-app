import {useMutation, useQuery, useQueryClient} from "@tanstack/react-query";
import {useCallback, useEffect, useMemo, useState} from "react";
import {adminQueryKeys} from "../../../shared/query/queryKeys";
import type {
  AdminClubClaimListRow,
  AdminClubClaimRequestDetails,
  ClubClaimDecision,
} from "../../../shared/types/adminTypes";
import {
  decideOrganizerClaim,
  listOrganizerClaimRequests,
  loadOrganizerClaimRequest,
} from "../api/organizerPublishingRepository";

export interface OrganizerClaimReviewController {
  approvalIssue: string | null;
  decisionInFlight: ClubClaimDecision | null;
  detailError: string | null;
  details: AdminClubClaimRequestDetails | null;
  filteredRows: AdminClubClaimListRow[];
  isDetailLoading: boolean;
  isLoading: boolean;
  generatedAt: string | null;
  note: string;
  query: string;
  rejectionIssue: string | null;
  rows: AdminClubClaimListRow[];
  selected: AdminClubClaimListRow | null;
  selectedRequestId: string | null;
  selectedUnavailable: boolean;
  validationIssue: string | null;
  decide: (decision: ClubClaimDecision) => Promise<boolean>;
  refresh: () => Promise<void>;
  refreshDetail: () => Promise<void>;
  select: (row: AdminClubClaimListRow) => void;
  setNote: (note: string) => void;
  setQuery: (query: string) => void;
}

export function useOrganizerClaimReviewController({
  enabled = true,
  onError,
  onNotice,
  onSelectedRequestIdChange,
  selectedRequestId: controlledSelectedRequestId,
}: {
  enabled?: boolean;
  onError: (message: string | null) => void;
  onNotice: (message: string | null) => void;
  onSelectedRequestIdChange?: (requestId: string | null) => void;
  selectedRequestId?: string | null;
}): OrganizerClaimReviewController {
  const queryClient = useQueryClient();
  const [localSelectedRequestId, setLocalSelectedRequestId] =
    useState<string | null>(null);
  const [query, setQuery] = useState("");
  const [note, setNote] = useState("");
  const selectedRequestId = controlledSelectedRequestId === undefined ?
    localSelectedRequestId :
    controlledSelectedRequestId;
  const setSelectedRequestId = useCallback((requestId: string | null) => {
    if (controlledSelectedRequestId === undefined) {
      setLocalSelectedRequestId(requestId);
    }
    onSelectedRequestIdChange?.(requestId);
  }, [controlledSelectedRequestId, onSelectedRequestIdChange]);
  const listQuery = useQuery({
    enabled,
    queryKey: adminQueryKeys.organizers.claims(),
    queryFn: listOrganizerClaimRequests,
  });
  const rows = listQuery.data?.rows ?? [];
  const selectedRow = rows.find((row) => row.requestId === selectedRequestId) ?? null;
  const detailQuery = useQuery({
    enabled: enabled && Boolean(selectedRequestId),
    queryKey: adminQueryKeys.organizers.claimDetail(selectedRequestId ?? "none"),
    queryFn: () => loadOrganizerClaimRequest({
      requestId: selectedRequestId ?? "",
    }),
  });
  const decisionMutation = useMutation({
    mutationFn: decideOrganizerClaim,
  });
  const filteredRows = useMemo(
    () => filterClaimRows(rows, query),
    [query, rows]
  );
  const details = detailQuery.data?.request ?? null;
  const selected = selectedRow ?? details;
  const validationIssue = validateClaimDecision(selected, details, note);
  const approvalIssue = validateClaimDecision(selected, details, note, "approve");
  const rejectionIssue = validateClaimDecision(selected, details, note, "reject");

  useEffect(() => {
    if (listQuery.isError) {
      onError(messageFromError(
        listQuery.error,
        "Unable to load organizer claim requests."
      ));
      return;
    }
    if (listQuery.isSuccess && !detailQuery.isError) onError(null);
  }, [detailQuery.isError, listQuery.error, listQuery.isError, listQuery.isSuccess, onError]);

  useEffect(() => {
    if (detailQuery.isError) {
      onError(messageFromError(
        detailQuery.error,
        "Unable to load organizer claim evidence."
      ));
      return;
    }
    if (detailQuery.isSuccess && !listQuery.isError) onError(null);
  }, [detailQuery.error, detailQuery.isError, detailQuery.isSuccess, listQuery.isError, onError]);

  const select = useCallback((row: AdminClubClaimListRow) => {
    setSelectedRequestId(row.requestId);
    setNote("");
    onError(null);
  }, [onError, setSelectedRequestId]);

  const decide = useCallback(async (decision: ClubClaimDecision) => {
    if (!selected) {
      onError("Select an organizer claim before deciding.");
      return false;
    }
    const issue = validateClaimDecision(selected, details, note, decision);
    if (issue) {
      onError(issue);
      return false;
    }
    try {
      const result = await decisionMutation.mutateAsync({
        requestId: selected.requestId,
        decision,
        decisionReason: note.trim(),
      });
      queryClient.setQueryData(
        adminQueryKeys.organizers.claims(),
        (current: typeof listQuery.data) => current ? {
          ...current,
          rows: current.rows.filter((row) =>
            row.requestId !== selected.requestId
          ),
        } : current
      );
      await Promise.all([
        queryClient.invalidateQueries({
          queryKey: adminQueryKeys.organizers.claims(),
        }),
        queryClient.invalidateQueries({
          queryKey: adminQueryKeys.organizers.detail(result.clubId),
        }),
        queryClient.invalidateQueries({
          queryKey: [...adminQueryKeys.all, "overview"],
        }),
      ]);
      setSelectedRequestId(null);
      setNote("");
      onError(null);
      onNotice(
        `${decision === "approve" ? "Approved" : "Rejected"} ` +
          `${selected.requesterName}'s organizer claim.`
      );
      return true;
    } catch (error) {
      onError(messageFromError(error, "Unable to decide organizer claim."));
      return false;
    }
  }, [decisionMutation, details, note, onError, onNotice, queryClient, selected, setSelectedRequestId]);

  const refresh = useCallback(async () => {
    await listQuery.refetch();
  }, [listQuery]);

  const refreshDetail = useCallback(async () => {
    await detailQuery.refetch();
  }, [detailQuery]);

  const detailError = detailQuery.isError ? messageFromError(
    detailQuery.error,
    "Unable to load organizer claim evidence."
  ) : null;

  return {
    approvalIssue,
    decisionInFlight: decisionMutation.isPending ?
      decisionMutation.variables?.decision ?? null :
      null,
    detailError,
    details,
    filteredRows,
    generatedAt: listQuery.data?.generatedAt ?? null,
    isDetailLoading: Boolean(selectedRequestId) &&
      (detailQuery.isPending || detailQuery.isFetching),
    isLoading: listQuery.isPending || listQuery.isFetching,
    note,
    query,
    rejectionIssue,
    rows,
    selected,
    selectedRequestId,
    selectedUnavailable: Boolean(
      selectedRequestId &&
      !detailQuery.isPending &&
      (detailQuery.isError || !details)
    ),
    validationIssue,
    decide,
    refresh,
    refreshDetail,
    select,
    setNote,
    setQuery,
  };
}

function filterClaimRows(
  rows: AdminClubClaimListRow[],
  query: string
): AdminClubClaimListRow[] {
  const tokens = query.trim().toLowerCase().split(/\s+/u).filter(Boolean);
  if (tokens.length === 0) return rows;
  return rows.filter((row) => {
    const haystack = [
      row.requestId,
      row.clubId,
      row.requesterUid,
      row.requesterName,
      row.requesterRole,
      row.contact,
      row.status,
    ].join(" ").toLowerCase();
    return tokens.every((token) => haystack.includes(token));
  });
}

function validateClaimDecision(
  selected: AdminClubClaimListRow | null,
  details: AdminClubClaimRequestDetails | null,
  note: string,
  decision: ClubClaimDecision | null = null
): string | null {
  if (!selected) return "Select an organizer claim before deciding.";
  if (!details) return "Load the claim evidence before deciding.";
  if (!note.trim()) return "Add a review note before approving or rejecting.";
  if (note.trim().length > 1000) {
    return "Review note must be 1000 characters or fewer.";
  }
  if (decision === "approve" && !details.club.exists) {
    return "The organizer document is missing and cannot be approved.";
  }
  if (decision === "approve" && !details.requesterProfile.exists) {
    return "The requester does not have a Catch profile yet.";
  }
  if (decision === "approve" && !details.requesterProfile.profileComplete) {
    return "The requester must complete their Catch profile before approval.";
  }
  return null;
}

function messageFromError(error: unknown, fallback: string): string {
  if (error && typeof error === "object" && "message" in error) {
    const message = String(error.message ?? "").trim();
    if (message) return message;
  }
  return fallback;
}
