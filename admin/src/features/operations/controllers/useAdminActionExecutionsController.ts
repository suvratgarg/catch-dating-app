import {useMutation, useQuery, useQueryClient} from "@tanstack/react-query";
import {useCallback, useEffect, useMemo, useState} from "react";

import {adminQueryKeys} from "../../../shared/query/queryKeys";
import type {
  AdminActionExecutionRecord,
  AdminActionExecutionStatus,
  AdminListActionExecutionsResponse,
} from "../../../shared/types/adminTypes";
import {loadAdminActionExecutions} from
  "../api/adminActionExecutionRepository";

const pageLimit = 50;

export type AdminActionExecutionStatusFilter =
  | "all"
  | AdminActionExecutionStatus;

export interface AdminActionExecutionsController {
  actionFilter: string;
  generatedAt: string | null;
  hasMore: boolean;
  isLoading: boolean;
  isLoadingMore: boolean;
  query: string;
  rows: AdminActionExecutionRecord[];
  statusFilter: AdminActionExecutionStatusFilter;
  visibleRows: AdminActionExecutionRecord[];
  loadMore: () => Promise<boolean>;
  refresh: () => Promise<boolean>;
  setActionFilter: (value: string) => void;
  setQuery: (value: string) => void;
  setStatusFilter: (value: AdminActionExecutionStatusFilter) => void;
}

export function useAdminActionExecutionsController({
  onError,
}: {
  onError: (message: string | null) => void;
}): AdminActionExecutionsController {
  const queryClient = useQueryClient();
  const queryKey = adminQueryKeys.operations.executions();
  const [query, setQuery] = useState("");
  const [actionFilter, setActionFilter] = useState("all");
  const [statusFilter, setStatusFilter] =
    useState<AdminActionExecutionStatusFilter>("all");
  const executionQuery = useQuery({
    queryKey,
    queryFn: () => loadAdminActionExecutions({limit: pageLimit}),
    retry: false,
  });
  const rows = executionQuery.data?.rows ?? [];
  const visibleRows = useMemo(
    () => filterAdminActionExecutions(
      rows,
      {actionFilter, query, statusFilter}
    ),
    [actionFilter, query, rows, statusFilter]
  );

  useEffect(() => {
    if (executionQuery.isError) {
      onError(messageFromError(
        executionQuery.error,
        "Unable to load agent activity."
      ));
      return;
    }
    if (executionQuery.isSuccess) onError(null);
  }, [
    executionQuery.error,
    executionQuery.isError,
    executionQuery.isSuccess,
    onError,
  ]);

  const refresh = useCallback(async () => {
    onError(null);
    const result = await executionQuery.refetch();
    if (!result.error) return true;
    onError(messageFromError(result.error, "Unable to refresh agent activity."));
    return false;
  }, [executionQuery, onError]);

  const loadMoreMutation = useMutation({
    mutationKey: [...queryKey, "load-more"],
    mutationFn: async () => {
      const current = queryClient.getQueryData<
        AdminListActionExecutionsResponse
      >(queryKey);
      if (!current?.nextCursor) return false;
      const page = await loadAdminActionExecutions({
        cursor: current.nextCursor,
        limit: pageLimit,
      });
      const merged = mergeAdminActionExecutionPages(current, page);
      let applied = false;
      queryClient.setQueryData<AdminListActionExecutionsResponse>(
        queryKey,
        (latest) => {
          if (!latest || latest.generatedAt !== current.generatedAt ||
              latest.nextCursor !== current.nextCursor) return latest;
          applied = true;
          return merged;
        }
      );
      return applied;
    },
    onError: (error: unknown) => {
      onError(messageFromError(
        error,
        "Unable to load more agent activity."
      ));
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

  return {
    actionFilter,
    generatedAt: executionQuery.data?.generatedAt ?? null,
    hasMore: Boolean(executionQuery.data?.nextCursor),
    isLoading: executionQuery.isLoading || executionQuery.isFetching,
    isLoadingMore: loadMoreMutation.isPending,
    query,
    rows,
    statusFilter,
    visibleRows,
    loadMore,
    refresh,
    setActionFilter,
    setQuery,
    setStatusFilter,
  };
}

export function filterAdminActionExecutions(
  rows: AdminActionExecutionRecord[],
  filters: {
    actionFilter: string;
    query: string;
    statusFilter: AdminActionExecutionStatusFilter;
  }
): AdminActionExecutionRecord[] {
  const query = filters.query.trim().toLocaleLowerCase();
  return rows.filter((row) =>
    (filters.actionFilter === "all" ||
      row.actionId === filters.actionFilter) &&
    (filters.statusFilter === "all" ||
      row.status === filters.statusFilter) &&
    (!query || [
      row.actionId,
      row.callable,
      row.actorUid,
      row.target,
      row.errorCode,
      row.errorMessage,
      row.executionId,
    ].filter(Boolean).join(" ").toLocaleLowerCase().includes(query))
  );
}

export function mergeAdminActionExecutionPages(
  current: AdminListActionExecutionsResponse,
  page: AdminListActionExecutionsResponse
): AdminListActionExecutionsResponse {
  const rows = new Map(current.rows.map((row) => [row.executionId, row]));
  for (const row of page.rows) rows.set(row.executionId, row);
  return {
    ...current,
    generatedAt: page.generatedAt,
    rows: [...rows.values()],
    nextCursor: page.nextCursor,
  };
}

function messageFromError(error: unknown, fallback: string): string {
  return error instanceof Error && error.message ? error.message : fallback;
}
