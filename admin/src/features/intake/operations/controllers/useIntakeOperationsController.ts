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

import {
  assertOperationReadPage,
  mergeUnavailableOperationRecords,
  unavailableOperationRecords,
  type OperationInventoryResponse,
} from "../../../../shared/operations/operationReadDiagnostics";

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
): Promise<OperationInventoryResponse> {
  const first = withOrganizerDraftLinks(await loader(payload));
  assertOperationReadPage(first);
  assertInventoryCardinality(first);
  const runId = first.runs[0]?.runId ?? null;
  if (!isWholeRunInventoryRequest(payload)) return first;
  assertTerminalInventoryCardinality(first);
  if (!runId) {
    assertCompleteExceptionInventory(first);
    return first;
  }

  const workItems = new Map(first.workItems.map((item) => [
    item.workItemId, item,
  ]));
  const organizerDraftLinks = new Map(
    organizerDraftLinksOf(first).map((link) => [link.workItemId, link])
  );
  let unavailableRecords = unavailableOperationRecords(first);
  const unavailableExceptions = new Set<string>();
  const seenCursors = new Set<string>();
  // Invalid first-page records might be exceptions. Restart the filtered
  // query so they can be accounted for without guessing their task flags.
  let cursor = unavailableRecords.length ? null : first.nextWorkItemCursor;
  const pageLimit = Math.ceil(
    first.summary.humanReviewCount / exceptionPageLimit
  ) + 2;
  let pageCount = 0;
  while (countHumanReviewItems(workItems.values()) +
      unavailableExceptions.size < first.summary.humanReviewCount) {
    if ((!cursor && pageCount > 0) ||
        (!cursor && unavailableRecords.length === 0)) break;
    if ((cursor && seenCursors.has(cursor)) || pageCount >= pageLimit) {
      throw new Error("Supply Intake exception pagination did not converge.");
    }
    if (cursor) seenCursors.add(cursor);
    const page = await loader({
      ...payload,
      runId,
      runCursor: null,
      workItemCursor: cursor,
      humanReviewRequired: true,
      workItemLimit: exceptionPageLimit,
    });
    assertPageForRun(page, first, runId, true);
    unavailableRecords = mergeUnavailableOperationRecords(
      unavailableRecords, page
    );
    for (const record of page.workItemPage?.unavailableRecords ?? []) {
      if (workItems.has(record.documentId)) {
        throw new Error("Supply Intake document availability changed between pages.");
      }
      unavailableExceptions.add(record.documentId);
    }
    for (const item of page.workItems) workItems.set(item.workItemId, item);
    for (const link of organizerDraftLinksOf(page)) {
      organizerDraftLinks.set(link.workItemId, link);
    }
    if (page.nextWorkItemCursor && page.nextWorkItemCursor === cursor) {
      throw new Error("Supply Intake exception pagination did not converge.");
    }
    cursor = page.nextWorkItemCursor;
    pageCount += 1;
  }

  const complete: OperationInventoryResponse = {
    ...first,
    workItems: [...workItems.values()],
    organizerDraftLinks: [...organizerDraftLinks.values()],
    readInventory: {
      unavailableRecords,
      humanReviewUnavailableDocumentIds: [...unavailableExceptions],
    },
    nextWorkItemCursor: workItems.size + unavailableRecords.length ===
      first.summary.workItemCount ? null : first.nextWorkItemCursor,
  };
  assertInventoryCardinality(complete);
  assertCompleteExceptionInventory(complete);
  return complete;
}

export async function loadNextIntakeOperationsPage(
  current: OperationInventoryResponse,
  loader: IntakeOperationsLoader = listIntakeOperations,
  payload: AdminListIntakeOperationsPayload = defaultPayload
): Promise<OperationInventoryResponse> {
  const runId = current.runs[0]?.runId ?? null;
  if (!runId || !current.nextWorkItemCursor) {
    return withOrganizerDraftLinks(current);
  }
  const page = withOrganizerDraftLinks(await loader({
    ...payload,
    runId,
    runCursor: null,
    workItemCursor: current.nextWorkItemCursor,
    humanReviewRequired: false,
  }));
  assertPageForRun(page, current, runId, false);
  const unavailableRecords = mergeUnavailableOperationRecords(
    unavailableOperationRecords(current), page
  );
  const workItems = new Map(current.workItems.map((item) => [
    item.workItemId, item,
  ]));
  for (const record of page.workItemPage?.unavailableRecords ?? []) {
    if (workItems.has(record.documentId)) {
      throw new Error("Supply Intake document availability changed between pages.");
    }
  }
  const organizerDraftLinks = new Map(
    organizerDraftLinksOf(current).map((link) => [link.workItemId, link])
  );
  for (const item of page.workItems) workItems.set(item.workItemId, item);
  for (const link of organizerDraftLinksOf(page)) {
    organizerDraftLinks.set(link.workItemId, link);
  }
  const loadedCount = workItems.size + unavailableRecords.length;
  if (loadedCount > current.summary.workItemCount) {
    throw new Error(
      "Supply Intake pagination exceeded its persisted run summary."
    );
  }
  if ((page.nextWorkItemCursor &&
        page.nextWorkItemCursor === current.nextWorkItemCursor) ||
      (!page.nextWorkItemCursor &&
        loadedCount < current.summary.workItemCount) ||
      (!page.workItemPage && loadedCount < current.summary.workItemCount &&
        workItems.size === current.workItems.length)) {
    throw new Error(
      "Supply Intake pagination ended or stalled before the persisted inventory was complete."
    );
  }
  return {
    ...current,
    generatedAt: page.generatedAt,
    workItems: [...workItems.values()],
    organizerDraftLinks: [...organizerDraftLinks.values()],
    readInventory: {
      unavailableRecords,
      humanReviewUnavailableDocumentIds:
        current.readInventory?.humanReviewUnavailableDocumentIds ?? [],
    },
    nextWorkItemCursor: loadedCount === current.summary.workItemCount ?
      null : page.nextWorkItemCursor,
  };
}

function assertTerminalInventoryCardinality(
  response: OperationInventoryResponse
): void {
  if (!response.nextWorkItemCursor &&
      response.workItems.length + unavailableOperationRecords(response).length !==
        response.summary.workItemCount) {
    throw new Error(
      "Supply Intake pagination ended before the persisted inventory was complete."
    );
  }
}

function assertInventoryCardinality(
  response: OperationInventoryResponse
): void {
  if (response.workItems.length + unavailableOperationRecords(response).length >
      response.summary.workItemCount) {
    throw new Error(
      "Supply Intake inventory exceeds its persisted run summary."
    );
  }
}

function assertCompleteExceptionInventory(
  response: OperationInventoryResponse
): void {
  const humanReviewCount = countHumanReviewItems(response.workItems);
  const unavailableCount =
    response.readInventory?.humanReviewUnavailableDocumentIds.length ?? 0;
  if (humanReviewCount + unavailableCount !== response.summary.humanReviewCount) {
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

function organizerDraftLinksOf(
  response: AdminListIntakeOperationsResponse
) {
  return response.organizerDraftLinks ?? [];
}

function withOrganizerDraftLinks(
  response: OperationInventoryResponse
): OperationInventoryResponse {
  if (response.organizerDraftLinks) return response;
  return {...response, organizerDraftLinks: []};
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
        OperationInventoryResponse
      >(queryKey);
      if (!current?.nextWorkItemCursor) return false;
      onError(null);
      const next = await loadNextIntakeOperationsPage(current);
      let applied = false;
      queryClient.setQueryData<OperationInventoryResponse>(
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
    errorMessage: operationsQuery.error instanceof Error ?
      operationsQuery.error.message :
      operationsQuery.isError ?
        "Unable to load Supply Intake operations." :
        null,
    isError: operationsQuery.isError,
    isLoading: operationsQuery.isPending && !operationsQuery.data,
    isRefreshing: operationsQuery.isFetching && Boolean(operationsQuery.data),
    isLoadingMore: loadMoreMutation.isPending,
    loadMore,
    refresh,
  };
}

export type IntakeOperationsController =
  ReturnType<typeof useIntakeOperationsController>;
