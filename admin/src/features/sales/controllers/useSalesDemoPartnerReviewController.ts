import {useMutation, useQuery, useQueryClient} from "@tanstack/react-query";
import {useEffect, useLayoutEffect, useMemo, useRef, useState} from "react";
import {useAdminPendingOperationGuard} from "../../../shared/pendingOperation";
import {salesDemoPartnerReviewApi, type SalesDemoPartnerReviewApi, type OwnerDemoShareInput} from "../api/salesDemoPartnerReview";
type Work = {run: () => Promise<unknown>};
export function useSalesDemoPartnerReviewController({actorUid, organizerId, blueprintId, blueprintRevision,
  parentAccessCurrent = true, api = salesDemoPartnerReviewApi}: {
  actorUid: string; organizerId: string; blueprintId: string; blueprintRevision: number;
  parentAccessCurrent?: boolean; api?: SalesDemoPartnerReviewApi;
}) {
  const client = useQueryClient(); const {beginOperation, endOperation} = useAdminPendingOperationGuard();
  const epoch = useRef(0); const pending = useRef<Work | null>(null);
  const [ticket, setTicket] = useState<Work | null>(null); const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null); const [notice, setNotice] = useState<string | null>(null);
  const scope = useMemo(() => ["owner-demo-review", actorUid, organizerId, blueprintId] as const,
    [actorUid, organizerId, blueprintId]);
  const query = useQuery({queryKey: [...scope, blueprintRevision], queryFn: () => api.get(blueprintId),
    enabled: parentAccessCurrent, retry: false, gcTime: 0, staleTime: 0, refetchInterval: 60_000});
  const currentData = query.isSuccess && !query.isFetching && query.data.organizerId === organizerId &&
    query.data.blueprintId === blueprintId && query.data.blueprintRevision === blueprintRevision ? query.data : null;
  const expiresAt = currentData ? Math.min(Date.parse(currentData.maximumExpiresAt), Date.parse(currentData.evaluatedAt) + 60_000) : 0;
  const reads = useRef({data: currentData, expiresAt, session: () => parentAccessCurrent});
  reads.current = {data: currentData, expiresAt, session: () => parentAccessCurrent};
  const readable = () => reads.current.session() && Date.now() < reads.current.expiresAt && reads.current.data !== null;
  const mutation = useMutation({mutationFn: (work: Work) => work.run(), retry: false, gcTime: 0});
  useLayoutEffect(() => {
    epoch.current += 1; pending.current = null; setTicket(null); setBusy(false); setError(null); setNotice(null);
    return () => {epoch.current += 1; pending.current = null;
      void client.cancelQueries({queryKey: scope}); client.removeQueries({queryKey: scope});};
  }, [client, scope]);
  useEffect(() => {
    if (!currentData || !parentAccessCurrent) return;
    const timer = window.setTimeout(() => {void client.invalidateQueries({queryKey: scope});},
      Math.max(0, Math.min(2_147_483_647, expiresAt - Date.now())));
    return () => window.clearTimeout(timer);
  }, [client, scope, currentData, expiresAt, parentAccessCurrent]);
  const refresh = () => parentAccessCurrent && reads.current.session() ? client.invalidateQueries({queryKey: scope}) : Promise.resolve();
  const run = async (work: Work) => {
    if (!readable() || (pending.current && pending.current !== work)) return false;
    const lease = beginOperation(); if (!lease) return false;
    const start = epoch.current; pending.current = work; setTicket(work); setBusy(true); setError(null); setNotice(null);
    try {
      await mutation.mutateAsync(work);
      if (start !== epoch.current || !reads.current.session()) return false;
      pending.current = null; setTicket(null); setNotice("Confirmed. Refreshing current review."); void refresh(); return true;
    } catch (failure) {
      if (start !== epoch.current) return false;
      const code = failure && typeof failure === "object" && "code" in failure ? String(failure.code).replace(/^functions\//u, "") : "";
      const definitive = ["aborted", "invalid-argument", "permission-denied", "unauthenticated", "failed-precondition",
        "already-exists", "not-found", "resource-exhausted"].includes(code);
      if (definitive) {pending.current = null; setTicket(null); void refresh();}
      setError(definitive ? "The action was rejected. Refresh and review current access." :
        "The action was not confirmed. Retry the unchanged request to recover it."); return false;
    } finally {if (start === epoch.current) {setBusy(false); mutation.reset();} endOperation(lease);}
  };
  const submit = (work: Work) => pending.current ? Promise.resolve(false) : run(work);
  const retry = () => pending.current ? run(pending.current) : Promise.resolve(false);
  const share = (decision: "share" | "withdraw", expires: string | null) => {
    const current = reads.current.data; if (!readable() || !current) return Promise.resolve(false);
    const frozen: OwnerDemoShareInput = {requestId: crypto.randomUUID(), blueprintId,
      expectedBlueprintRevision: current.blueprintRevision, expectedSharingRevision: current.sharingRevision,
      partnerUid: current.partnerUid, expectedAssignmentRevision: current.assignmentRevision,
      expectedPreviewHash: current.previewHash, decision, expiresAt: expires};
    return submit({run: () => api.share(frozen)});
  };
  return {query, data: readable() ? currentData : null, ticket, busy, error, notice, refresh, share, retry};
}
