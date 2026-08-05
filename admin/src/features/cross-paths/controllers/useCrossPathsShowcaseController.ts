import {useMutation, useQuery, useQueryClient} from "@tanstack/react-query";
import {useCallback, useEffect, useState} from "react";
import type {AdminListCrossPathsShowcaseCandidatesCallableResponse} from
  "../../../generated/contracts/adminListCrossPathsShowcaseCandidatesCallableResponse";
import type {AdminSetCrossPathsShowcaseEligibilityCallablePayload} from
  "../../../generated/contracts/adminSetCrossPathsShowcaseEligibilityCallablePayload";
import {adminQueryKeys} from "../../../shared/query/queryKeys";
import {useAdminPendingOperationGuard} from
  "../../../shared/pendingOperation";
import {
  loadCrossPathsShowcaseReviewPage,
  saveCrossPathsShowcaseDecision,
} from "../api/crossPathsShowcaseRepository";

export type CrossPathsShowcaseFilter =
  "all" | "eligible" | "needsReview" | "paused";
export type CrossPathsShowcaseCandidate =
  AdminListCrossPathsShowcaseCandidatesCallableResponse["candidates"][number];
export type CrossPathsShowcaseDecision =
  AdminSetCrossPathsShowcaseEligibilityCallablePayload;

export interface CrossPathsShowcaseController {
  candidates: CrossPathsShowcaseCandidate[];
  cursor: string | null;
  decide: (payload: CrossPathsShowcaseDecision) => Promise<boolean>;
  errorMessage: string | null;
  filter: CrossPathsShowcaseFilter;
  generatedAt: string | null;
  isLoading: boolean;
  isMutating: boolean;
  loadNext: () => void;
  nextCursor: string | null;
  pendingUid: string | null;
  refresh: () => Promise<void>;
  setFilter: (filter: CrossPathsShowcaseFilter) => void;
}

export function useCrossPathsShowcaseController({
  onError,
  onNotice,
}: {
  onError: (message: string | null) => void;
  onNotice: (message: string | null) => void;
}): CrossPathsShowcaseController {
  const queryClient = useQueryClient();
  const {beginOperation, endOperation} = useAdminPendingOperationGuard();
  const [filter, setFilterState] =
    useState<CrossPathsShowcaseFilter>("needsReview");
  const [cursor, setCursor] = useState<string | null>(null);
  const queryKey = adminQueryKeys.crossPaths.showcase(filter, cursor);
  const queueQuery = useQuery({
    queryKey,
    queryFn: () => loadCrossPathsShowcaseReviewPage({
      status: filter,
      cursor,
      limit: 25,
    }),
    placeholderData: (previousData) => previousData,
  });
  const decisionMutation = useMutation({
    mutationFn: saveCrossPathsShowcaseDecision,
  });

  useEffect(() => {
    if (!queueQuery.error) return;
    onError(messageFromError(
      queueQuery.error,
      "Unable to load the Cross Paths showcase review queue."
    ));
  }, [onError, queueQuery.error]);

  const setFilter = useCallback((next: CrossPathsShowcaseFilter) => {
    setFilterState(next);
    setCursor(null);
  }, []);

  const refresh = useCallback(async () => {
    const result = await queueQuery.refetch();
    if (result.error) {
      onError(messageFromError(
        result.error,
        "Unable to refresh the Cross Paths showcase review queue."
      ));
      return;
    }
    onError(null);
    onNotice("Cross Paths showcase review queue refreshed.");
  }, [onError, onNotice, queueQuery]);

  const decide = useCallback(async (
    submitted: CrossPathsShowcaseDecision
  ): Promise<boolean> => {
    const payload: CrossPathsShowcaseDecision = {
      uid: submitted.uid.trim(),
      status: submitted.status,
      reviewChecklist: {...submitted.reviewChecklist},
      reviewNote: submitted.reviewNote.trim(),
    };
    if (!payload.reviewNote) {
      onError("Add a review note before recording a decision.");
      return false;
    }
    const operation = beginOperation();
    if (!operation) return false;
    try {
      await decisionMutation.mutateAsync(payload);
      await queryClient.invalidateQueries({
        queryKey: [...adminQueryKeys.all, "cross-paths"],
      });
      onError(null);
      onNotice(`Cross Paths showcase status updated for ${payload.uid}.`);
      return true;
    } catch (error) {
      onError(messageFromError(
        error,
        "Unable to update Cross Paths showcase eligibility."
      ));
      return false;
    } finally {
      endOperation(operation);
    }
  }, [
    beginOperation,
    decisionMutation,
    endOperation,
    onError,
    onNotice,
    queryClient,
  ]);

  return {
    candidates: queueQuery.data?.candidates ?? [],
    cursor,
    decide,
    errorMessage: queueQuery.error ? messageFromError(
      queueQuery.error,
      "Unable to load the Cross Paths showcase review queue."
    ) : null,
    filter,
    generatedAt: queueQuery.data?.generatedAt ?? null,
    isLoading: queueQuery.isPending || queueQuery.isFetching,
    isMutating: decisionMutation.isPending,
    loadNext: () => {
      if (queueQuery.data?.nextCursor) setCursor(queueQuery.data.nextCursor);
    },
    nextCursor: queueQuery.data?.nextCursor ?? null,
    pendingUid: decisionMutation.isPending ?
      decisionMutation.variables?.uid ?? null : null,
    refresh,
    setFilter,
  };
}

function messageFromError(error: unknown, fallback: string): string {
  if (error instanceof Error && error.message.trim()) return error.message;
  if (error && typeof error === "object" && "message" in error) {
    const message = (error as {message?: unknown}).message;
    if (typeof message === "string" && message.trim()) return message;
  }
  return fallback;
}
