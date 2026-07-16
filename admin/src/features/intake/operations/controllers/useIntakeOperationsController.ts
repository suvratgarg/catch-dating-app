import {useMutation, useQuery, useQueryClient} from "@tanstack/react-query";
import {useCallback, useEffect, useMemo} from "react";

import {adminQueryKeys} from
  "../../../../shared/query/queryKeys";
import type {AdminListIntakeOperationsPayload} from
  "../../../../shared/operations/operationsTypes";
import type {
  AdminListIntakeOperationsResponse,
  OperationWorkItem,
} from
  "../../../../shared/operations/operationsTypes";
import {operationNeedsHumanReview} from
  "../../../../shared/operations/operationSelectors";
import {listIntakeOperations} from
  "../api/intakeOperationsRepository";

const defaultPayload: AdminListIntakeOperationsPayload = {
  workflowId: "supply-intake",
  runLimit: 10,
  workItemLimit: 200,
};
const exceptionPageLimit = 200;

type IntakeOperationsLoader = (
  payload: AdminListIntakeOperationsPayload
) => Promise<AdminListIntakeOperationsResponse>;

export async function loadCompleteIntakeOperations(
  loader: IntakeOperationsLoader = listIntakeOperations,
  payload: AdminListIntakeOperationsPayload = defaultPayload
): Promise<AdminListIntakeOperationsResponse> {
  const first = await loader(payload);
  assertInventoryCardinality(first);
  const runId = first.runs[0]?.runId ?? null;
  if (!isWholeRunInventoryRequest(payload)) return first;
  if (!runId || !first.nextWorkItemCursor) {
    assertTerminalInventoryCardinality(first);
    assertCompleteExceptionInventory(first);
    return first;
  }

  const workItems = new Map(first.workItems.map((item) => [
    item.workItemId,
    item,
  ]));
  const seenCursors = new Set<string>();
  let cursor: string | null = first.nextWorkItemCursor;
  const pageLimit = Math.ceil(
    first.summary.humanReviewCount / exceptionPageLimit
  ) + 2;
  let pageCount = 1;
  while (cursor && countHumanReviewItems(workItems.values()) <
      first.summary.humanReviewCount) {
    if (seenCursors.has(cursor) || pageCount >= pageLimit) {
      throw new Error("Supply Intake exception pagination did not converge.");
    }
    seenCursors.add(cursor);
    const page = await loader({
      ...payload,
      runId,
      runCursor: null,
      workItemCursor: cursor,
      humanReviewRequired: true,
      workItemLimit: exceptionPageLimit,
    });
    assertPageForRun(page, first, runId, true);
    for (const item of page.workItems) {
      workItems.set(item.workItemId, item);
    }
    cursor = page.nextWorkItemCursor;
    pageCount += 1;
  }

  const complete = {
    ...first,
    workItems: [...workItems.values()],
    nextWorkItemCursor: workItems.size === first.summary.workItemCount ?
      null : first.nextWorkItemCursor,
  };
  assertInventoryCardinality(complete);
  assertCompleteExceptionInventory(complete);
  return complete;
}

export async function loadNextIntakeOperationsPage(
  current: AdminListIntakeOperationsResponse,
  loader: IntakeOperationsLoader = listIntakeOperations,
  payload: AdminListIntakeOperationsPayload = defaultPayload
): Promise<AdminListIntakeOperationsResponse> {
  const runId = current.runs[0]?.runId ?? null;
  if (!runId || !current.nextWorkItemCursor) return current;
  const page = await loader({
    ...payload,
    runId,
    runCursor: null,
    workItemCursor: current.nextWorkItemCursor,
    humanReviewRequired: false,
  });
  assertPageForRun(page, current, runId, false);
  const workItems = new Map(current.workItems.map((item) => [
    item.workItemId,
    item,
  ]));
  for (const item of page.workItems) workItems.set(item.workItemId, item);
  if (workItems.size > current.summary.workItemCount) {
    throw new Error(
      "Supply Intake pagination exceeded its persisted run summary."
    );
  }
  if (workItems.size < current.summary.workItemCount &&
      (workItems.size === current.workItems.length ||
        !page.nextWorkItemCursor ||
        page.nextWorkItemCursor === current.nextWorkItemCursor)) {
    throw new Error(
      "Supply Intake pagination ended or stalled before the persisted inventory was complete."
    );
  }
  return {
    ...current,
    generatedAt: page.generatedAt,
    workItems: [...workItems.values()],
    nextWorkItemCursor: workItems.size === current.summary.workItemCount ?
      null : page.nextWorkItemCursor,
  };
}

function assertTerminalInventoryCardinality(
  response: AdminListIntakeOperationsResponse
): void {
  if (!response.nextWorkItemCursor &&
      response.workItems.length !== response.summary.workItemCount) {
    throw new Error(
      "Supply Intake pagination ended before the persisted inventory was complete."
    );
  }
}

function assertInventoryCardinality(
  response: AdminListIntakeOperationsResponse
): void {
  if (response.workItems.length > response.summary.workItemCount) {
    throw new Error(
      "Supply Intake inventory exceeds its persisted run summary."
    );
  }
}

function assertCompleteExceptionInventory(
  response: AdminListIntakeOperationsResponse
): void {
  const humanReviewCount = countHumanReviewItems(response.workItems);
  if (humanReviewCount !== response.summary.humanReviewCount) {
    throw new Error(
      "Supply Intake exception inventory is incomplete relative to its persisted run summary."
    );
  }
}

function assertPageForRun(
  page: AdminListIntakeOperationsResponse,
  first: AdminListIntakeOperationsResponse,
  runId: string,
  exceptionsOnly: boolean
): void {
  if (page.runs[0]?.runId !== runId ||
      page.workItems.some((item) => item.runId !== runId)) {
    throw new Error("Supply Intake pagination crossed run boundaries.");
  }
  if (page.summary.workItemCount !== first.summary.workItemCount ||
      page.summary.humanReviewCount !== first.summary.humanReviewCount ||
      JSON.stringify(page.summary.stages) !==
        JSON.stringify(first.summary.stages)) {
    throw new Error("Supply Intake pagination summary changed between pages.");
  }
  if (exceptionsOnly && page.workItems.some((item) =>
    !operationNeedsHumanReview(item))) {
    throw new Error("Supply Intake exception query returned an ordinary item.");
  }
}

function isWholeRunInventoryRequest(
  payload: AdminListIntakeOperationsPayload
): boolean {
  return !payload.primaryStage &&
    !payload.entityKind &&
    !payload.lifecycleStatus &&
    !payload.humanReviewRequired &&
    !payload.workItemCursor;
}

function countHumanReviewItems(items: Iterable<OperationWorkItem>): number {
  let count = 0;
  for (const item of items) {
    if (operationNeedsHumanReview(item)) count += 1;
  }
  return count;
}

export function useIntakeOperationsController({
  onError,
}: {
  onError: (message: string | null) => void;
}) {
  const payloadKey = JSON.stringify(defaultPayload);
  const queryClient = useQueryClient();
  const queryKey = useMemo(
    () => adminQueryKeys.intakeOperations.list(payloadKey),
    [payloadKey]
  );
  const operationsQuery = useQuery({
    queryKey,
    queryFn: () => loadCompleteIntakeOperations(),
    retry: false,
  });

  const refresh = useCallback(async () => {
    onError(null);
    const result = await operationsQuery.refetch();
    if (!result.error) return true;
    onError(result.error instanceof Error ?
      result.error.message :
      "Unable to load Supply Intake operations.");
    return false;
  }, [onError, operationsQuery]);

  const loadMoreMutation = useMutation({
    mutationKey: [...queryKey, "load-more"],
    mutationFn: async () => {
      const current = queryClient.getQueryData<
        AdminListIntakeOperationsResponse
      >(queryKey);
      if (!current?.nextWorkItemCursor) return false;
      onError(null);
      const next = await loadNextIntakeOperationsPage(current);
      let applied = false;
      queryClient.setQueryData<AdminListIntakeOperationsResponse>(
        queryKey,
        (latest) => {
          if (!latest ||
              latest.runs[0]?.runId !== current.runs[0]?.runId ||
              latest.generatedAt !== current.generatedAt ||
              latest.nextWorkItemCursor !== current.nextWorkItemCursor) {
            return latest;
          }
          applied = true;
          return next;
        }
      );
      return applied;
    },
    onError: (error: unknown) => {
      onError(error instanceof Error ?
        error.message :
        "Unable to load more Supply Intake operations.");
    },
  });

  const loadMore = useCallback(async () => {
    if (loadMoreMutation.isPending) return false;
    try {
      return await loadMoreMutation.mutateAsync();
    } catch {
      return false;
    }
  }, [loadMoreMutation]);

  useEffect(() => {
    if (operationsQuery.isError) {
      onError(operationsQuery.error instanceof Error ?
        operationsQuery.error.message :
        "Unable to load Supply Intake operations.");
      return;
    }
    if (operationsQuery.isSuccess) onError(null);
  }, [
    onError,
    operationsQuery.error,
    operationsQuery.isError,
    operationsQuery.isSuccess,
  ]);

  return {
    data: operationsQuery.data ?? null,
    isLoading: operationsQuery.isPending || operationsQuery.isFetching,
    isLoadingMore: loadMoreMutation.isPending,
    loadMore,
    refresh,
  };
}

export type IntakeOperationsController =
  ReturnType<typeof useIntakeOperationsController>;
