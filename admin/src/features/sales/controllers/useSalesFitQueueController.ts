import {useQuery, useQueryClient} from "@tanstack/react-query";
import {useCallback, useEffect, useMemo, useRef, useState} from "react";
import {useAdminPendingOperationGuard} from "../../../shared/pendingOperation";
import {salesFitQueueApi} from "../api/salesFitQueueRepository";
import type {FitBatchResult, FitQueueApi, FitQueueView} from
  "../api/salesFitQueueTypes";

type Pending =
  | {kind: "host"; organizerId: string; requestId: string}
  | {kind: "batch"; requestId: string; cursor?: string; limit: 10};
const definitive = new Set(["aborted", "invalid-argument",
  "permission-denied", "unauthenticated", "failed-precondition",
  "already-exists", "not-found", "resource-exhausted"]);
function codeOf(error: unknown): string {
  return error && typeof error === "object" && "code" in error ?
    String(error.code).replace(/^functions\//u, "") : "";
}

export function useSalesFitQueueController({actorUid,
  api = salesFitQueueApi}: {actorUid: string; api?: FitQueueApi}) {
  const client = useQueryClient();
  const {beginOperation, endOperation} = useAdminPendingOperationGuard();
  const scope = useMemo(() => ["sales-fit-queue", actorUid] as const,
    [actorUid]);
  const [view, setView] = useState<FitQueueView>("ranked");
  const [cursor, setCursor] = useState<string | undefined>();
  const [history, setHistory] = useState<Array<string | undefined>>([]);
  const [batchRequestId, setBatchRequestId] = useState<string | null>(null);
  const [nextBatchCursor, setNextBatchCursor] = useState<string | null>(null);
  const [lastBatch, setLastBatch] = useState<FitBatchResult | null>(null);
  const [retryTicket, setRetryTicket] = useState<Pending | null>(null);
  const pendingRef = useRef<Pending | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");
  const [notice, setNotice] = useState("");
  const page = useQuery({queryKey: [...scope, "page", view, cursor],
    queryFn: () => api.list(view, cursor), retry: false});

  const resetPage = useCallback(() => {
    setCursor(undefined);
    setHistory([]);
    void client.invalidateQueries({queryKey: [...scope, "page"]});
  }, [client, scope]);
  useEffect(() => {
    if (!cursor || codeOf(page.error) !== "aborted") return;
    resetPage();
    setNotice("The ranking changed. The view restarted at the first page.");
  }, [cursor, page.error, resetPage]);
  useEffect(() => () => {
    pendingRef.current = null;
    client.removeQueries({queryKey: scope});
  }, [client, scope]);

  const changeView = useCallback((next: FitQueueView) => {
    if (next === view) return;
    setView(next);
    setCursor(undefined);
    setHistory([]);
    setError("");
    setNotice("");
  }, [view]);
  const nextPage = useCallback(() => {
    if (!page.data?.nextCursor) return;
    setHistory((old) => [...old, cursor]);
    setCursor(page.data.nextCursor ?? undefined);
  }, [cursor, page.data]);
  const previousPage = useCallback(() => {
    if (!history.length) return;
    setCursor(history.at(-1));
    setHistory(history.slice(0, -1));
  }, [history]);

  const run = useCallback(async (ticket: Pending): Promise<boolean> => {
    const lease = beginOperation();
    if (!lease) return false;
    setBusy(true);
    setError("");
    setNotice("");
    try {
      if (ticket.kind === "host") {
        const result = await api.refresh(ticket);
        setNotice(result.entry.score === null ?
          "Fit refreshed. Reviewed evidence is still incomplete or disputed." :
          "Current reviewed fit refreshed for this host.");
      } else {
        const result = await api.refreshBatch(ticket);
        setBatchRequestId(ticket.requestId);
        setNextBatchCursor(result.nextCursor);
        setLastBatch(result);
        setNotice(result.nextCursor ?
          "This batch finished. Continue to review the next hosts." :
          "The bounded fit refresh reached the end of the host list.");
      }
      pendingRef.current = null;
      setRetryTicket(null);
      resetPage();
      return true;
    } catch (failure) {
      const code = codeOf(failure);
      if (definitive.has(code)) {
        pendingRef.current = null;
        setRetryTicket(null);
        if (code === "aborted") {
          resetPage();
          setError("The reviewed source changed. The ranking restarted; review it before refreshing again.");
        } else {
          setError(failure instanceof Error ? failure.message :
            "Fit refresh was rejected. Review current sources before retrying.");
        }
      } else {
        pendingRef.current = ticket;
        setRetryTicket(ticket);
        setError("Refresh was not confirmed. Retry this same request before starting another.");
      }
      return false;
    } finally {
      setBusy(false);
      endOperation(lease);
    }
  }, [api, beginOperation, endOperation, resetPage]);
  const refreshHost = useCallback((organizerId: string) => {
    if (pendingRef.current) return Promise.resolve(false);
    const ticket: Pending = {kind: "host", organizerId,
      requestId: crypto.randomUUID()};
    pendingRef.current = ticket;
    setRetryTicket(ticket);
    return run(ticket);
  }, [run]);
  const startBatch = useCallback(() => {
    if (pendingRef.current) return Promise.resolve(false);
    const ticket: Pending = {kind: "batch", requestId: crypto.randomUUID(),
      limit: 10};
    pendingRef.current = ticket;
    setRetryTicket(ticket);
    setBatchRequestId(ticket.requestId);
    setNextBatchCursor(null);
    setLastBatch(null);
    return run(ticket);
  }, [run]);
  const continueBatch = useCallback(() => {
    if (pendingRef.current || !batchRequestId || !nextBatchCursor) {
      return Promise.resolve(false);
    }
    const ticket: Pending = {kind: "batch", requestId: batchRequestId,
      cursor: nextBatchCursor, limit: 10};
    pendingRef.current = ticket;
    setRetryTicket(ticket);
    return run(ticket);
  }, [batchRequestId, nextBatchCursor, run]);
  const retryPending = useCallback(() => pendingRef.current ?
    run(pendingRef.current) : Promise.resolve(false), [run]);
  return {view, changeView, page, cursor, history, nextPage, previousPage,
    refreshHost, startBatch, continueBatch, retryPending,
    nextBatchCursor, lastBatch, pending: retryTicket, busy, error, notice};
}
