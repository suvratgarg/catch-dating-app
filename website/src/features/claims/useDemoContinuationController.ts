import {continuationCopy} from "../../content/salesDemoContinuation";
import {useMutation, useQuery} from "@tanstack/react-query";
import {useEffect, useRef, useState} from "react";
import type {SalesDemoAuth, SalesDemoViewer} from "../../shared/auth/salesDemoAuth";
import type {SalesDemoContinuationApi} from "../../shared/domain/salesDemoHandoff";

export function useDemoContinuationController(continuationId: string,
  api: SalesDemoContinuationApi, auth: SalesDemoAuth) {
  const [viewer, setViewer] = useState<SalesDemoViewer | null>(null);
  const [authReady, setAuthReady] = useState(false);
  const [authEpoch, setAuthEpoch] = useState(0);
  const epoch = useRef(0);
  const locked = useRef(false);
  const [notice, setNotice] = useState("");
  useEffect(() => auth.watch((next) => {
    epoch.current += 1; setAuthEpoch(epoch.current);
    setViewer(next); setAuthReady(true); setNotice("");
  }), [auth]);
  useEffect(() => () => {epoch.current += 1;}, []);
  const query = useQuery({queryKey: ["sales-demo-continuation", continuationId,
    viewer?.uid ?? null, authEpoch],
  enabled: authReady && Boolean(viewer) && /^[a-f0-9]{64}$/u.test(continuationId),
  queryFn: () => api.get({continuationId}), retry: false, staleTime: 0, gcTime: 0});
  const current = query.isSuccess && !query.isFetching &&
    query.data.continuationId === continuationId &&
    Date.parse(query.data.expiresAt) > Date.now() ? query.data : null;
  const prepare = useMutation({retry: false, gcTime: 0, mutationFn: async () => {
    if (locked.current || !viewer || current?.setup.status !== "ready") return;
    locked.current = true; setNotice("");
    const startedEpoch = epoch.current;
    try {
      await api.prepare({continuationId, setupHash: current.setup.setupHash});
    } catch (error) {
      if (epoch.current === startedEpoch) setNotice(error instanceof Error ? error.message : continuationCopy.refreshBeforeRetry);
    } finally {
      // Always reconcile a possibly committed transaction before another mutation.
      if (epoch.current === startedEpoch) await query.refetch();
      locked.current = false;
    }
  }});
  return {viewer, authReady, authEpoch, query, current, notice,
    pending: prepare.isPending, prepare: () => prepare.mutateAsync()};
}
